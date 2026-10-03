#!/usr/bin/env bash
# rds_lab.sh | --cleanup — a PostgreSQL database done right, in the private subnets of the Module 03 VPC:
#   not public · encrypted · automated backups (7 days) · deletion protection · password in Secrets Manager (never seen)
# Run vpc_lab.sh first. Local AWS: instant. ☁️ Real AWS: ~10 minutes to create, free tier db.t4g.micro — then --cleanup!
set -euo pipefail
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
vpc=$(aws ec2 describe-vpcs --filters Name=tag:project,Values=vpc-lab --query 'Vpcs[0].VpcId' --output text)
[[ $vpc != None ]] || { echo "run ../../03-networking-vpc/solutions/vpc_lab.sh first" >&2; exit 1; }

if [[ ${1:-} == --cleanup ]]; then
    aws rds modify-db-instance --db-instance-identifier demo-db --no-deletion-protection --apply-immediately > /dev/null 2>&1 || true
    aws rds delete-db-instance --db-instance-identifier demo-db --skip-final-snapshot > /dev/null 2>&1 || true
    aws rds wait db-instance-deleted --db-instance-identifier demo-db 2>/dev/null || true
    aws rds delete-db-subnet-group --db-subnet-group-name demo-db 2>/dev/null || true
    echo "deleted demo-db (☁️ in real life: take a final snapshot unless it's a lab)"; exit 0
fi

say "1. A subnet group: which (private!) subnets the database may live in"
# shellcheck disable=SC2046  # several subnet ids
aws rds create-db-subnet-group --db-subnet-group-name demo-db --db-subnet-group-description "private subnets" \
    --subnet-ids $(aws ec2 describe-subnets --filters Name=vpc-id,Values="$vpc" Name=tag:Name,Values='private-*' --query 'Subnets[].SubnetId' --output text) \
    --query 'DBSubnetGroup.Subnets[].SubnetAvailabilityZone.Name' --output text

say "2. The database"
db_sg=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values="$vpc" Name=group-name,Values=db --query 'SecurityGroups[0].GroupId' --output text)
aws rds create-db-instance --db-instance-identifier demo-db \
    --engine postgres --db-instance-class db.t4g.micro --allocated-storage 20 --storage-type gp3 \
    --master-username demo --manage-master-user-password \
    --db-subnet-group-name demo-db --vpc-security-group-ids "$db_sg" --no-publicly-accessible \
    --storage-encrypted --backup-retention-period 7 --deletion-protection \
    --tags Key=project,Value=rds-lab > /dev/null
aws rds wait db-instance-available --db-instance-identifier demo-db
aws rds describe-db-instances --db-instance-identifier demo-db --query 'DBInstances[0].{
    Engine: Engine, Class: DBInstanceClass, Public: PubliclyAccessible, Encrypted: StorageEncrypted,
    Backups: BackupRetentionPeriod, Protected: DeletionProtection, Endpoint: Endpoint.Address,
    Secret: MasterUserSecret.SecretArn}' --output table

echo
echo "The app reads the password from Secrets Manager at start-up (its role needs secretsmanager:GetSecretValue)."
echo "✅ clean up with: $0 --cleanup"
