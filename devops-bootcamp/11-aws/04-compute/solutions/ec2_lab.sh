#!/usr/bin/env bash
# ec2_lab.sh | --cleanup — launch demo-app on EC2 the modern way, with the AWS CLI:
#   latest Amazon Linux AMI from SSM · an instance ROLE for SSM Session Manager (no SSH keys, no open port 22)
#   · a launch template with user data and IMDSv2 required · a t3.micro tagged project=ec2-lab
# Runs on local AWS (nothing really boots there) or ☁️ a real account (free tier: t3.micro/t2.micro — then --cleanup!)
set -euo pipefail
cd "$(dirname "$0")"
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

if [[ ${1:-} == --cleanup ]]; then
    ids=$(aws ec2 describe-instances --filters Name=tag:project,Values=ec2-lab Name=instance-state-name,Values=pending,running,stopped \
        --query 'Reservations[].Instances[].InstanceId' --output text)
    if [[ -n $ids ]]; then
        # shellcheck disable=SC2086  # several ids
        aws ec2 terminate-instances --instance-ids $ids > /dev/null
        # shellcheck disable=SC2086
        aws ec2 wait instance-terminated --instance-ids $ids
    fi
    aws ec2 delete-launch-template --launch-template-name demo-app > /dev/null 2>&1 || true
    aws iam remove-role-from-instance-profile --instance-profile-name demo-app --role-name demo-app-ec2 2>/dev/null || true
    aws iam delete-instance-profile --instance-profile-name demo-app 2>/dev/null || true
    aws iam detach-role-policy --role-name demo-app-ec2 --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>/dev/null || true
    aws iam delete-role --role-name demo-app-ec2 2>/dev/null || true
    echo "cleaned up: ${ids:-no instances}"; exit 0
fi

say "1. The newest Amazon Linux 2023 AMI — from a public SSM parameter (never hard-code AMI ids)"
ami=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --query 'Parameters[0].Value' --output text)
echo "$ami"

say "2. An instance role so SSM Session Manager works — log in without SSH keys or open ports"
aws iam create-role --role-name demo-app-ec2 --assume-role-policy-document file://../../02-iam/solutions/policies/trust-ec2.json > /dev/null
aws iam attach-role-policy --role-name demo-app-ec2 --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name demo-app > /dev/null
aws iam add-role-to-instance-profile --instance-profile-name demo-app --role-name demo-app-ec2
sleep 10                                                    # IAM is eventually consistent: give it a moment

say "3. A launch template: AMI + type + role + user data + IMDSv2 — the recipe Auto Scaling will reuse"
user_data=$(base64 -w0 user-data.sh)
aws ec2 create-launch-template --launch-template-name demo-app --launch-template-data "{
  \"ImageId\": \"$ami\",
  \"InstanceType\": \"t3.micro\",
  \"IamInstanceProfile\": {\"Name\": \"demo-app\"},
  \"UserData\": \"$user_data\",
  \"MetadataOptions\": {\"HttpTokens\": \"required\", \"HttpPutResponseHopLimit\": 1},
  \"TagSpecifications\": [{\"ResourceType\": \"instance\", \"Tags\": [{\"Key\": \"project\", \"Value\": \"ec2-lab\"}, {\"Key\": \"Name\", \"Value\": \"demo-app\"}]}]
}" --query 'LaunchTemplate.{Name: LaunchTemplateName, Version: LatestVersionNumber}' --output table
# shellcheck disable=SC2016  # '$Latest' is a literal AWS keyword, not a shell variable
aws ec2 describe-launch-template-versions --launch-template-name demo-app --versions '$Latest' \
    --query 'LaunchTemplateVersions[0].LaunchTemplateData.{IMDSv2: MetadataOptions.HttpTokens, Role: IamInstanceProfile.Name, Type: InstanceType}' --output table

say "4. Launch one instance from the template"
id=$(aws ec2 run-instances --launch-template LaunchTemplateName=demo-app --count 1 --query 'Instances[0].InstanceId' --output text)
aws ec2 wait instance-running --instance-ids "$id"
aws ec2 describe-instances --instance-ids "$id" \
    --query 'Reservations[0].Instances[0].{Id: InstanceId, Type: InstanceType, State: State.Name, AZ: Placement.AvailabilityZone, IMDS: MetadataOptions.HttpTokens, Profile: IamInstanceProfile.Arn}' --output table

echo
echo "☁️  On real AWS: aws ssm start-session --target $id     then: curl localhost:8000"
echo "✅ clean up with: $0 --cleanup"
