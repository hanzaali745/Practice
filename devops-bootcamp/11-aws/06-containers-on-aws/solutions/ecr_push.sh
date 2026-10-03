#!/usr/bin/env bash
# ecr_push.sh [TAG] — a private ECR repository done right, then build and push demo-app to it
#   immutable tags · scan on push · lifecycle (keep 20 releases, drop untagged after 7 days)
# Local AWS: the repository part works (push does not — moto has no real registry). ☁️ Real AWS: all of it.
set -euo pipefail
cd "$(dirname "$0")"
repo=demo-app
tag=${1:-sha-$(git rev-parse --short HEAD 2>/dev/null || echo dev)}
account=$(aws sts get-caller-identity --query Account --output text)
region=${AWS_REGION:-$(aws configure get region)}
registry="$account.dkr.ecr.$region.amazonaws.com"

if ! aws ecr describe-repositories --repository-names "$repo" > /dev/null 2>&1; then
    aws ecr create-repository --repository-name "$repo" \
        --image-tag-mutability IMMUTABLE \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=KMS > /dev/null
    aws ecr put-lifecycle-policy --repository-name "$repo" --lifecycle-policy-text file://ecr-lifecycle.json > /dev/null
    echo "created $registry/$repo"
fi
aws ecr describe-repositories --repository-names "$repo" \
    --query 'repositories[0].{URI: repositoryUri, Tags: imageTagMutability, ScanOnPush: imageScanningConfiguration.scanOnPush}' --output table

if [[ -n ${AWS_ENDPOINT_URL:-} ]]; then
    echo "local AWS: skipping docker login/push (moto has no real registry)"; exit 0
fi

aws ecr get-login-password | docker login --username AWS --password-stdin "$registry"
docker build -t "$registry/$repo:$tag" --build-arg VERSION="$tag" ../../../8-cicd/lab-repo
docker push "$registry/$repo:$tag"
aws ecr wait image-scan-complete --repository-name "$repo" --image-id imageTag="$tag" || true
aws ecr describe-image-scan-findings --repository-name "$repo" --image-id imageTag="$tag" \
    --query 'imageScanFindings.findingSeverityCounts' --output table
echo "✅ pushed $registry/$repo:$tag"
