#!/usr/bin/env bash
# install_into.sh LAB_REPO — add the AWS deployment to your lab repo (which already has the Phase 8 capstone pipeline)
#   ./install_into.sh ~/cicd-lab
set -euo pipefail
src=$(cd "$(dirname "$0")" && pwd)
repo=${1:?usage: install_into.sh LAB_REPO}
[[ -d $repo/.git ]] || { echo "$repo is not a git repository" >&2; exit 1; }
[[ -f $repo/.github/workflows/ci.yml ]] || { echo "$repo has no ci.yml: install the Phase 8 capstone pipeline first" >&2; exit 1; }

mkdir -p "$repo/docs" "$repo/infra"
cp "$src/pipeline/.github/workflows/deploy-aws.yml" "$repo/.github/workflows/"
cp "$src/pipeline/scripts/ecs_deploy.sh" "$repo/scripts/"
cp "$src/pipeline/docs/runbook.md" "$repo/docs/"
cp -r "$src/infra/." "$repo/infra/"
rm -rf "$repo/infra/.terraform" "$repo/infra/.terraform.lock.hcl" "$repo"/infra/terraform.tfstate*
cd "$repo"
git add -A
git commit -qm "Deploy to AWS: Terraform infrastructure, deploy-aws workflow (OIDC → ECR → ECS), runbook"
echo "✅ committed in $repo — next: README step 2 (terraform apply)"
