# AWS Module 01 — Cloud Basics & a Safe Account 🟢

## 🎯 Objectives
- Explain the cloud model, regions, availability zones and the shared responsibility model
- Set up an AWS account **safely**: root MFA, no root keys, an admin identity, a budget, CloudTrail
- Sign in to the CLI with **IAM Identity Center (SSO)** — short-lived credentials, no keys on disk
- Practise for free with the **local fake AWS** (moto)
- Check an account's safety automatically with a script

## 🧠 Why DevOps engineers care
AWS is the most used cloud, and most DevOps jobs touch it daily. The first lesson every team learns — usually the hard
way — is that cloud mistakes cost real money and leak real data: a leaked access key can mine crypto on your bill within
hours. Engineers who set accounts up safely from day one are trusted with production.

---

## 📖 Lesson 1.1 — The cloud in five ideas

| Idea | Meaning |
|------|---------|
| **On demand** | create a server, database or bucket with an API call; delete it and stop paying |
| **Region** | a geographic area (`eu-west-1` Ireland, `us-east-1` N. Virginia) — data stays where you put it |
| **Availability Zone (AZ)** | separate data centres inside a region; spread across ≥ 2 for high availability |
| **Shared responsibility** | AWS secures the cloud (hardware, facilities); **you** secure what's in it (IAM, data, config, patches) |
| **Pay as you go** | per second / GB / request — fantastic for experiments, dangerous when forgotten |

Service families you'll meet: **IAM** (who), **VPC** (network), **EC2** (servers), **S3/EBS/RDS/DynamoDB** (data),
**ECR/ECS/EKS/Lambda** (containers and functions), **CloudWatch/CloudTrail** (watching).

## 📖 Lesson 1.2 — A safe account, in order

1. Sign up → you're the **root user**. Enable **MFA** on root (console → *Security credentials*). Never create root
   access keys. Store the root password in a password manager — you'll almost never use it again.
2. Turn on **IAM Identity Center** and create yourself a user with the `AdministratorAccess` permission set. Use that
   for everything from now on.
3. Run [`setup_safety.sh`](solutions/setup_safety.sh) as that admin: a **$10 budget** with e-mail alerts at 50% / 80%
   / forecast 100%, an account-wide **CloudTrail** trail (an audit log of every API call), and a **password policy**.
4. Pick **one region** for the course and stay in it (resources in forgotten regions are a classic surprise bill).
5. Run [`account_check.py`](solutions/account_check.py) — re-run it whenever you're unsure.

## 📖 Lesson 1.3 — The CLI with SSO

```bash
aws --version                               # aws-cli/2.x (Part 3 setup)
aws configure sso                           # or copy solutions/aws-config.example to ~/.aws/config
aws sso login --sso-session bootcamp
export AWS_PROFILE=lab
aws sts get-caller-identity                 # who am I? — run it before anything destructive
aws ec2 describe-regions --query 'Regions[].RegionName' --output table
```
Credentials come and go every few hours; nothing long-lived sits in `~/.aws/credentials`. In CI you use OIDC instead
(Phase 8, Module 05). Useful global flags: `--region`, `--profile`, `--output table|json|text`, `--query` (JMESPath),
`--dry-run` (EC2).

## 📖 Lesson 1.4 — Practise for free: local AWS

[`local-aws/`](../local-aws/README.md) runs **moto**, a fake AWS on your laptop:
```bash
cd ~/Practice/devops-bootcamp/11-aws/local-aws && docker compose up -d
source env.sh                                # this shell → http://localhost:5000
aws sts get-caller-identity                  # account 123456789012
aws s3 mb s3://hello && aws s3 ls
source env.sh off                            # back to real AWS
```
The AWS CLI and boto3 both honour `AWS_ENDPOINT_URL`, so every command and script in this phase works the same way
against moto. Nothing really runs there (no instances boot), but the APIs, responses and errors are realistic — and it
costs nothing. Labs marked **☁️** need a real account.

## 📖 Lesson 1.5 — How a surprise bill happens (and how you avoid it)

- Something left running: NAT gateways (~$1/day each), load balancers, big instances, EKS control planes
- Something in a region you never look at
- A leaked access key (in Git, in a screenshot) — bots scan GitHub within minutes
- Data transfer out to the internet

Habits: budgets with alerts · tags on everything (`project=bootcamp`, `owner=you`) · **destroy the same day** ·
`Cost Explorer` once a week · never long-lived keys.

---

## ⚠️ Common mistakes
- Working as root, or creating root access keys
- IAM users with access keys on laptops instead of SSO
- No budget alert — finding out from the monthly invoice
- Resources scattered over several regions
- Committing `~/.aws/credentials` or keys in code

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Labs 1 and 3 run on local AWS; Lab 2 needs **☁️ a real account**.

### Lab 1 ⭐ — Local AWS
Start the local AWS, `source env.sh`, and run `aws sts get-caller-identity`, `aws s3 mb`, `aws s3 ls`, `./reset.sh`.
Use `--query` and `--output table` to print only bucket names.

### Lab 2 ⭐⭐ — ☁️ A safe real account
Create a free AWS account and do Lesson 1.2 step by step: root MFA, IAM Identity Center admin, SSO profile, then
`setup_safety.sh`. Screenshot the budget and the CloudTrail trail.

### Lab 3 ⭐⭐ — Check it automatically
Run `account_check.py` on local AWS (several ❌), then `setup_safety.sh`, then the check again — which ❌ is left and
why can't a script fix it? Run it against your real account too.

### Lab 4 ⭐ — Cost thinking
Use the AWS Pricing Calculator to estimate a month of: 2 × `t3.micro`, an Application Load Balancer, a NAT gateway,
20 GB of S3. Which item surprised you?

---

## ✅ Checkpoint
- [ ] I can explain regions, AZs and the shared responsibility model
- [ ] My account has root MFA, no root keys, an SSO admin, a budget, CloudTrail and a password policy
- [ ] I use the CLI with SSO profiles and `--query`
- [ ] I can practise against local AWS and switch back to real AWS safely

👉 Next: [Module 02 — IAM](../02-iam/README.md)
