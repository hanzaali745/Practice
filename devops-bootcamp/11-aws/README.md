# ☁️ Phase 11: AWS

> **Before you start:** finish Phase 8 (CI/CD); the capstone deploys the Phase 8 lab repo. Install the AWS CLI v2 and
> the Python packages from [Part 3 setup](../00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md).
> **Free by default:** almost every lab runs against **local AWS** ([`local-aws/`](local-aws/README.md), moto in
> Docker), with the same `aws` commands, boto3 code and Terraform. Labs marked **☁️** need a real account: set it up
> safely in Module 01 (MFA, budget alarm, SSO) and **destroy what you create the same day**.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Cloud Basics & a Safe Account](01-cloud-and-account-setup/README.md) | 🟢 | regions/AZs, shared responsibility, MFA, budgets, SSO, local AWS |
| 02 | [IAM](02-iam/README.md) | 🟢 | users vs roles, policies, least privilege, conditions, an IAM audit script |
| 03 | [Networking: VPC](03-networking-vpc/README.md) | 🟡 | CIDR planning, public/private subnets, routes, NAT, security groups |
| 04 | [Compute: EC2, Auto Scaling & ALB](04-compute/README.md) | 🟡 | user data, IMDSv2, SSM, launch templates, ASG + ALB in Terraform |
| 05 | [Storage & Databases](05-storage-and-databases/README.md) | 🟡 | safe S3, versions, presigned URLs, RDS done right, DynamoDB, boto3 + moto tests |
| 06 | [Containers on AWS](06-containers-on-aws/README.md) | 🔴 | ECR, ECS Fargate behind an ALB, circuit breaker, autoscaling, EKS choices |
| 07 | [Serverless & Monitoring](07-serverless-and-monitoring/README.md) | 🔴 | Lambda, EventBridge, CloudWatch logs/metrics/alarms, SNS, CloudTrail |
| 08 | [AWS Capstone](08-capstone/README.md) | 🏆 | Terraform + OIDC pipeline → ECR → ECS, alarms with runbooks, `terraform test` |

## Cheat sheet

```bash
aws sts get-caller-identity          aws configure sso / aws sso login --profile x      aws configure list
aws ec2 describe-instances --filters Name=tag:env,Values=dev --query 'Reservations[].Instances[].[InstanceId,State.Name]' --output table
aws ssm start-session --target i-0abc          aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-0abc
aws s3 ls / cp / sync --delete      aws s3api list-object-versions --bucket b      aws s3 presign s3://b/k --expires-in 900
aws ecr get-login-password | docker login --username AWS --password-stdin <acct>.dkr.ecr.<region>.amazonaws.com
aws ecs describe-services --cluster c --services s      aws ecs update-service --cluster c --service s --force-new-deployment
aws logs tail /ecs/demo-app --follow --filter-pattern '{ $.log.level = "error" }'
aws cloudwatch describe-alarms --state-value ALARM      aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=X
aws iam simulate-principal-policy --policy-source-arn <role> --action-names s3:GetObject
source local-aws/env.sh   # → local AWS          source local-aws/env.sh off   # → real AWS
```

## 🏅 AWS expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Set up an account safely (root MFA, no root keys, budget alarm, SSO) and explain the shared responsibility model
- [ ] Write least-privilege IAM policies with conditions, use roles instead of keys everywhere, and audit an account
- [ ] Design a VPC across two AZs with public and private subnets, and explain every route and security group rule
- [ ] Run a self-healing, auto-scaling service behind an ALB, on EC2 and on ECS Fargate
- [ ] Choose the right storage (S3, EBS, EFS, RDS, DynamoDB) and make it private, encrypted, versioned and backed up
- [ ] Ship containers through ECR with immutable tags and roll them out safely, with automatic rollback
- [ ] Automate AWS with boto3 and Lambda + EventBridge, and test that code offline with moto
- [ ] Turn logs into metrics, metrics into alarms and alarms into notifications that link a runbook
- [ ] Deploy from GitHub Actions with OIDC (no stored keys) and keep all infrastructure in tested Terraform
- [ ] Estimate what a design costs, and tear everything down when you're done

👉 Start: [Module 01 — Cloud Basics & a Safe Account](01-cloud-and-account-setup/README.md)
