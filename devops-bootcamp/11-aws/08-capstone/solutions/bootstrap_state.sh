#!/usr/bin/env bash
# bootstrap_state.sh — ☁️ create the S3 bucket that holds Terraform state (once per account and region)
#   private · versioned (every state version can be recovered) · encrypted · TLS only
# Then uncomment the backend "s3" block in infra/versions.tf and run: terraform init -migrate-state
set -euo pipefail
account=$(aws sts get-caller-identity --query Account --output text)
region=${AWS_REGION:-$(aws configure get region)}
bucket="tfstate-$account-$region"

if aws s3api head-bucket --bucket "$bucket" > /dev/null 2>&1; then
    echo "$bucket already exists"; exit 0
fi
if [[ $region == us-east-1 ]]; then
    aws s3api create-bucket --bucket "$bucket"
else
    aws s3api create-bucket --bucket "$bucket" --create-bucket-configuration LocationConstraint="$region"
fi > /dev/null
aws s3api put-public-access-block --bucket "$bucket" --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$bucket" --server-side-encryption-configuration \
    '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}, "BucketKeyEnabled": true}]}'
aws s3api put-bucket-policy --bucket "$bucket" --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{\"Sid\": \"TlsOnly\", \"Effect\": \"Deny\", \"Principal\": \"*\", \"Action\": \"s3:*\",
        \"Resource\": [\"arn:aws:s3:::$bucket\", \"arn:aws:s3:::$bucket/*\"],
        \"Condition\": {\"Bool\": {\"aws:SecureTransport\": \"false\"}}}]}"
echo "✅ s3://$bucket — set bucket = \"$bucket\" in the backend block of infra/versions.tf"
