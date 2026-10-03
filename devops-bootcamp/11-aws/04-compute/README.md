# AWS Module 04 — Compute: EC2, Auto Scaling & Load Balancers 🟡

## 🎯 Objectives
- Choose instance types and find the latest AMI the right way (SSM public parameters)
- Bootstrap instances with **user data** (cloud-init) — demo-app as a systemd service
- Log in with **SSM Session Manager** instead of SSH keys; require **IMDSv2**
- Package all of that in a **launch template**
- Run a self-healing, auto-scaling fleet behind an **Application Load Balancer**, with rolling replacements
- Do it with the CLI first, then with Terraform — and test the Terraform against local AWS

## 🧠 Why DevOps engineers care
EC2 is still the backbone of AWS — even containers and Kubernetes nodes run on it. The pattern in this module (launch
template + Auto Scaling group + load balancer + health checks) is how you get servers that replace themselves when they
die and scale with traffic. It's also what Phase 7 (Ansible) and Phase 6 (Terraform) look like together in the cloud.

---

## 📖 Lesson 4.1 — Instances in one table

| Choice | Guidance |
|--------|----------|
| **Family** | `t` (burstable, cheap: labs, small apps) · `m` (general) · `c` (CPU) · `r` (memory) · `g` (GPU); `…g` suffix = Graviton (ARM, ~20% cheaper) |
| **AMI** | never hard-code ids: `aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` |
| **Pricing** | On-Demand · Savings Plans/Reserved (1–3 yr, −40–70%) · **Spot** (−70–90%, can be taken back: stateless workers only) |
| **Storage** | EBS gp3 root volume; instance store vanishes on stop |
| **Access** | an instance **role** (never keys) + **SSM Session Manager** (no port 22, no key pairs, every session logged) |
| **Metadata** | require **IMDSv2** (`HttpTokens: required`) — blocks a whole class of SSRF credential theft |

## 📖 Lesson 4.2 — User data

[`user-data.sh`](solutions/user-data.sh) runs once, as root, on first boot: creates a user, downloads `app.py`, asks the
metadata service (IMDSv2 token first!) for its instance id, writes a systemd unit and starts demo-app. Debug it on the
instance: `sudo cat /var/log/cloud-init-output.log`.

User data is great for small bootstraps. For anything bigger: bake an image (Packer), run Ansible (Phase 7), or use
containers (Module 06).

## 📖 Lesson 4.3 — Launch templates

```bash
./solutions/ec2_lab.sh          # latest AMI · role + instance profile · launch template with user data + IMDSv2 · one instance
./solutions/ec2_lab.sh --cleanup
```
A launch template is the versioned recipe — AMI, type, role, security groups, user data, metadata options — that
`run-instances`, Auto Scaling and Spot fleets all reuse. New version = new recipe; old versions stay for rollback.

## 📖 Lesson 4.4 — Auto Scaling + Application Load Balancer

```
internet ──► ALB :80 (public subnets) ──► target group (health check GET /health) ──► ASG: 2-4 instances (private subnets)
                                                                                     ▲ replaces unhealthy instances
                                                    CloudWatch CPU > 50% ────────────┘ scales out / in
```
- **Target group health checks**: unhealthy targets get no traffic; with `health_check_type = "ELB"` the ASG also
  *replaces* them.
- **Target tracking**: "keep average CPU at 50%" — AWS adds/removes instances for you.
- **Instance refresh**: change the launch template (new `app_version`) → instances are replaced in a rolling way,
  keeping ≥ 50% healthy. That's a zero-downtime deploy on EC2.

[`terraform/`](solutions/terraform/) builds exactly this in the VPC from Module 03 (found through data sources by tag).

## 📖 Lesson 4.5 — Test Terraform for free against local AWS

The AWS provider honours `AWS_ENDPOINT_URL` too, so with local AWS running you can **apply** real Terraform:
```bash
source ../local-aws/env.sh
../03-networking-vpc/solutions/vpc_lab.sh                      # the VPC the Terraform looks up
cd solutions/terraform
terraform init && terraform apply -var app_url=https://example.com/app.py
aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances'   # 2 instances (pretend ones)
terraform destroy -var app_url=x && ../../../03-networking-vpc/solutions/vpc_lab.sh --cleanup
```
It proves your references, data sources and resource arguments fit together — the instances don't really boot, so
the user data and health checks are only tested on ☁️ real AWS. (moto also doesn't copy every launch-template setting
onto instances; `ec2_lab.sh` therefore checks IMDSv2 and the role on the template itself.)

---

## ⚠️ Common mistakes
- SSH keys and port 22 open to the world (use SSM)
- Access keys on instances instead of an instance role
- IMDSv1 allowed; hard-coded AMI ids that go stale
- Instances in public subnets just to download packages (use NAT or VPC endpoints)
- `health_check_type = "EC2"` — the ASG never notices the app is down, only the VM
- Forgetting the load balancer and NAT gateway are running all night (they cost money while idle)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Labs 1–3 run on local AWS; Lab 4 needs **☁️ a real account**.

### Lab 1 ⭐ — Find things
With the CLI: the newest Amazon Linux 2023 AMI (x86 and ARM), the price of `t3.micro` vs `t4g.micro` in your region
(Pricing Calculator), the instance types available in one AZ.

### Lab 2 ⭐⭐ — An instance done right
Write `user-data.sh` and `ec2_lab.sh`: role + instance profile for SSM, launch template with IMDSv2 required, one
instance, `--cleanup`.

### Lab 3 ⭐⭐⭐ — ALB + ASG as code
Write the Terraform in `solutions/terraform/` and apply it against local AWS on top of the Module 03 VPC. Show the ASG
has 2 instances and one target group, then destroy it all.

### Lab 4 ⭐⭐⭐ — ☁️ The real thing
In a real account (with `vpc_lab.sh --with-nat`): apply the Terraform with your `app_url`, `curl` the URL several times
(different instance ids answer), terminate an instance and watch the ASG replace it, change `app_version` and watch the
instance refresh. `terraform destroy` + `vpc_lab.sh --cleanup` the same day.

---

## ✅ Checkpoint
- [ ] I pick instance types and AMIs sensibly, and use roles, SSM and IMDSv2
- [ ] I bootstrap with user data and package configuration in a launch template
- [ ] I can run an ASG behind an ALB with health checks, scaling and rolling refreshes
- [ ] I test AWS Terraform against local AWS before spending money

👉 Next: [Module 05 — Storage & Databases](../05-storage-and-databases/README.md)
