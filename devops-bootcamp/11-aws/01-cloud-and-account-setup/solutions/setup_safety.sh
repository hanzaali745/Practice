#!/usr/bin/env bash
# setup_safety.sh EMAIL — the first things to do in a new AWS account (as an admin user, NOT root):
#   a $10 monthly budget with e-mail alerts, an account-wide CloudTrail trail, and a strong password policy
set -euo pipefail
cd "$(dirname "$0")"
email=${1:?usage: setup_safety.sh YOUR-EMAIL}
account=$(aws sts get-caller-identity --query Account --output text)
region=${AWS_REGION:-$(aws configure get region || echo eu-west-1)}
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

echo "== budget: alert at 50%, 80% and a forecast over 100% of \$10/month"
sed "s/you@example.com/$email/" budget-notifications.json > "$tmp/notifications.json"
aws budgets create-budget --account-id "$account" --budget file://budget.json \
    --notifications-with-subscribers "file://$tmp/notifications.json"

echo "== CloudTrail: who did what, in every region, kept in S3"
bucket="cloudtrail-$account-$region"
aws s3api create-bucket --bucket "$bucket" --create-bucket-configuration "LocationConstraint=$region" > /dev/null
aws s3api put-public-access-block --bucket "$bucket" --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
cat > "$tmp/trail-policy.json" <<JSON
{"Version": "2012-10-17", "Statement": [
  {"Sid": "AclCheck", "Effect": "Allow", "Principal": {"Service": "cloudtrail.amazonaws.com"},
   "Action": "s3:GetBucketAcl", "Resource": "arn:aws:s3:::$bucket"},
  {"Sid": "Write", "Effect": "Allow", "Principal": {"Service": "cloudtrail.amazonaws.com"},
   "Action": "s3:PutObject", "Resource": "arn:aws:s3:::$bucket/AWSLogs/$account/*",
   "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}}]}
JSON
aws s3api put-bucket-policy --bucket "$bucket" --policy "file://$tmp/trail-policy.json"
aws cloudtrail create-trail --name account-trail --s3-bucket-name "$bucket" --is-multi-region-trail > /dev/null
aws cloudtrail start-logging --name account-trail

echo "== password policy for IAM users"
aws iam update-account-password-policy --minimum-password-length 14 --require-symbols --require-numbers \
    --require-uppercase-characters --require-lowercase-characters --max-password-age 90 --password-reuse-prevention 5

echo "✅ done — now run: python3 account_check.py  (root MFA is set by hand in the console)"
