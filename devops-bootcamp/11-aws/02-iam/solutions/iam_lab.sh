#!/usr/bin/env bash
# iam_lab.sh — groups, users, customer-managed policies, a role and AssumeRole, with the AWS CLI.
# Run it against local AWS (source ../../local-aws/env.sh) — or a real sandbox account, then ./iam_lab.sh --cleanup
set -euo pipefail
cd "$(dirname "$0")"
account=$(aws sts get-caller-identity --query Account --output text)
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

if [[ ${1:-} == --cleanup ]]; then
    aws iam remove-user-from-group --group-name developers --user-name alice 2>/dev/null || true
    aws iam detach-group-policy --group-name developers --policy-arn "arn:aws:iam::$account:policy/s3-read-reports" 2>/dev/null || true
    aws iam detach-role-policy --role-name reports-reader --policy-arn "arn:aws:iam::$account:policy/s3-read-reports" 2>/dev/null || true
    aws iam delete-user --user-name alice 2>/dev/null || true
    aws iam delete-group --group-name developers 2>/dev/null || true
    aws iam delete-role --role-name reports-reader 2>/dev/null || true
    aws iam delete-policy --policy-arn "arn:aws:iam::$account:policy/s3-read-reports" 2>/dev/null || true
    echo "cleaned up"; exit 0
fi

say "1. A customer-managed policy: read ONE bucket"
policy_arn=$(aws iam create-policy --policy-name s3-read-reports \
    --policy-document file://policies/s3-read-one-bucket.json --query Policy.Arn --output text)
echo "$policy_arn"

say "2. Permissions go to GROUPS, people go into groups"
aws iam create-group --group-name developers > /dev/null
aws iam attach-group-policy --group-name developers --policy-arn "$policy_arn"
aws iam create-user --user-name alice --tags Key=team,Value=platform > /dev/null
aws iam add-user-to-group --group-name developers --user-name alice
aws iam list-groups-for-user --user-name alice --query 'Groups[].GroupName' --output text

say "3. A ROLE: an identity with no password or keys — someone (or something) assumes it"
cat > /tmp/trust.json <<JSON
{"Version": "2012-10-17", "Statement": [{"Effect": "Allow",
  "Principal": {"AWS": "arn:aws:iam::$account:root"}, "Action": "sts:AssumeRole"}]}
JSON
role_arn=$(aws iam create-role --role-name reports-reader --assume-role-policy-document file:///tmp/trust.json \
    --max-session-duration 3600 --query Role.Arn --output text)
aws iam attach-role-policy --role-name reports-reader --policy-arn "$policy_arn"
echo "$role_arn"

say "4. Assume it: temporary credentials that expire"
aws sts assume-role --role-arn "$role_arn" --role-session-name lab-session --duration-seconds 900 \
    --query 'Credentials.{AccessKeyId: AccessKeyId, Expires: Expiration}' --output table

say "5. What does alice end up with?"
aws iam list-attached-group-policies --group-name developers --query 'AttachedPolicies[].PolicyName' --output text
aws iam get-policy-version --policy-arn "$policy_arn" --version-id v1 \
    --query 'PolicyVersion.Document.Statement[].{Sid: Sid, Action: Action}' --output table

echo; echo "✅ done — clean up with: $0 --cleanup"
