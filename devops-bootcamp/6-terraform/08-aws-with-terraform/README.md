# Terraform Module 08 — Terraform on AWS (optional) 🔴

> **Optional module.** It needs an AWS account and a payment card. Everything is designed to stay within the
> free tier / free credits **if you destroy resources the same day**. If you'd rather not use AWS yet, do the
> labs as **validate-only** (`terraform init && terraform validate` checks your code against the real AWS provider
> without an account) and come back later.

## 🎯 Objectives
- Set up an AWS account **safely** (MFA, no root keys, a budget alarm)
- Configure the AWS provider and credentials the right way
- Build a real network: VPC, subnet, internet gateway, routes, security group
- Launch an EC2 web server with cloud-init and find it with data sources
- Create an S3 bucket for **remote state** with versioning, encryption and no public access
- Destroy everything and check nothing is left running

## 🧠 Why DevOps engineers care
AWS is the most common cloud in DevOps job ads, and Terraform is how teams manage it. Every concept from
Modules 01–07 — providers, references, variables, state, loops, modules — now builds real servers on the internet.

---

## 📖 Lesson 8.1 — Account safety first (do this before anything else)

1. Turn on **MFA for the root user**; then never use root again (no root access keys, ever).
2. Create an admin identity for yourself — **IAM Identity Center** (recommended) or an IAM user with MFA.
3. **AWS Budgets → create a budget** of e.g. $5/month with email alerts at 50% and 100%.
4. Pick one region for all labs (e.g. `eu-west-1`) — forgotten resources in other regions are a classic surprise bill.

## 📖 Lesson 8.2 — Credentials

```bash
aws configure sso                 # IAM Identity Center (recommended) — short-lived credentials
# or: aws configure --profile lab # access keys for an IAM user (keep them OUT of Git!)
aws sts get-caller-identity --profile lab     # who am I?
export AWS_PROFILE=lab
```
The provider reads credentials from the environment/profile — **never** write keys in `.tf` files:
```hcl
provider "aws" {
  region = var.region
  default_tags {                 # added to EVERY resource — great for cost reports
    tags = {
      Project   = "devops-bootcamp"
      ManagedBy = "terraform"
      Owner     = var.owner
    }
  }
}
```
In CI, use **OIDC** (GitHub Actions → an IAM role) instead of long-lived keys.

## 📖 Lesson 8.3 — Data sources for the cloud

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {                           # always the latest Ubuntu 24.04 image
  most_recent = true
  owners      = ["099720108477"]                    # Canonical's official account
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_caller_identity" "current" {}
```

## 📖 Lesson 8.4 — A network and a web server

```
 VPC 10.0.0.0/16
 └── public subnet 10.0.1.0/24 (AZ a) ── route 0.0.0.0/0 → Internet Gateway
       └── EC2 "web" (Ubuntu + nginx via cloud-init)  ← security group: 80 from anywhere, 22 from YOUR IP only
```
The full, commented code is in [`solutions/web-server/`](solutions/web-server/). The key parts:

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.lab.key_name
  user_data              = file("${path.module}/cloud-init.yaml")   # installs nginx on first boot

  metadata_options {
    http_tokens = "required"     # IMDSv2 only — a security best practice
  }
}

output "url" {
  value = "http://${aws_instance.web.public_ip}/"
}
```
```bash
terraform apply -var "my_ip=$(curl -s https://checkip.amazonaws.com)/32"
curl "$(terraform output -raw url)"          # nginx answers from your server in the cloud 🎉
ssh ubuntu@"$(terraform output -raw public_ip)"
terraform destroy                            # ALWAYS, at the end of the session
```

## 📖 Lesson 8.5 — A bucket for remote state

[`solutions/state-bucket/`](solutions/state-bucket/) creates an S3 bucket with versioning (recover old state),
encryption, all public access blocked, and `prevent_destroy`. Then other projects use it:

```hcl
terraform {
  backend "s3" {
    bucket       = "devops-bootcamp-tfstate-123456789012"
    key          = "web-server/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
```
```bash
terraform init -migrate-state
```

## 📖 Lesson 8.6 — Cost hygiene

- `terraform destroy` at the end of **every** session; check the EC2 console (all regions!) afterwards
- Billing → **Cost Explorer** once a week while learning
- Avoid NAT gateways, load balancers and big instances in labs — they cost money even when idle
- Tag everything (`default_tags`) so you can see what costs what

---

## ⚠️ Common mistakes
- Using root credentials, or committing access keys (bots scan GitHub for them within minutes)
- SSH open to `0.0.0.0/0`
- Forgetting `destroy`, or resources left in another region
- Hard-coding AMI IDs (they differ per region and get outdated) — use the `aws_ami` data source
- Public S3 buckets

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). `./validate.sh` validates both configs without an AWS account.

### Lab 1 ⭐ — Safe account
Do Lesson 8.1 completely and take a screenshot of your budget alert. (No code — but the most important lab.)

### Lab 2 ⭐⭐ — Web server
Apply `web-server/` with your IP for SSH. `curl` the URL, SSH in, `systemctl status nginx`. Change the cloud-init
page text and notice in the plan that changing `user_data` **replaces** the instance (Module 02!). Destroy.

### Lab 3 ⭐⭐ — State bucket
Apply `state-bucket/` (its state stays local — it's the "bootstrap" project). Then add the `backend "s3"` block to
`web-server/` and `terraform init -migrate-state`. Find the state object in S3. Destroy the web server; keep the bucket.

### Lab 4 ⭐⭐⭐ — Refactor into modules
Split `web-server/` into a `network` module (VPC, subnet, IGW, routes) and a `web` module (SG, key, instance), wired
together with outputs/inputs. Use `moved` blocks so applying the refactor changes nothing in AWS.

---

## ✅ Checkpoint
- [ ] My account has MFA, no root keys, and a budget alarm
- [ ] I configure credentials via profiles/SSO/OIDC, never in code
- [ ] I can build a VPC, subnet, routes, security group and EC2 instance with Terraform
- [ ] I store state in an encrypted, versioned, private S3 bucket with locking
- [ ] I destroy what I build and check the bill

👉 Next: [Module 09 — Workflow, Testing & CI](../09-workflow-testing-ci/README.md)
