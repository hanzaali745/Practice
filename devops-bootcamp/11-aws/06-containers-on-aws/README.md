# AWS Module 06 — Containers on AWS: ECR, ECS Fargate & EKS 🔴

## 🎯 Objectives
- Store images in a private **ECR** repository: immutable tags, scan on push, lifecycle rules
- Run demo-app on **ECS Fargate** behind an ALB, with no servers to manage
- Separate the **execution role** (ECS pulling and logging) from the **task role** (what your code can do)
- Ship safe deployments: rolling updates, the **deployment circuit breaker** and **autoscaling**
- Know when to choose ECS, EKS, App Runner or Lambda

## 🧠 Why DevOps engineers care
Phase 4 built the image, Phase 5 ran it on Kubernetes and Phase 8 shipped it through a pipeline. This module is where
those images run in the cloud. Most AWS container platforms are ECS or EKS with ECR beside them, and the choice between
them is a question every DevOps engineer gets asked.

---

## 📖 Lesson 6.1 — ECR: your private registry

```bash
./solutions/ecr_push.sh            # repository + lifecycle; ☁️ on real AWS also builds and pushes demo-app
```
| Setting | Why |
|---------|-----|
| **Immutable tags** | `sha-abc123` always means the same image; nobody can overwrite a release |
| **Scan on push** | known CVEs show up in the console and EventBridge (Trivy from Phase 8 still runs in CI) |
| **KMS encryption** | encrypted at rest with an auditable key |
| **Lifecycle** ([`ecr-lifecycle.json`](solutions/ecr-lifecycle.json)) | untagged images expire after 7 days; keep the 20 newest `sha-` images for rollbacks |

Login is `aws ecr get-login-password | docker login --password-stdin <account>.dkr.ecr.<region>.amazonaws.com`. In CI,
use `aws-actions/configure-aws-credentials` with **OIDC** (Phase 8, Module 06), never stored keys.

## 📖 Lesson 6.2 — ECS in one picture

```
cluster ─ service "demo-app" (desired 2, rolling, circuit breaker)
            └─ tasks ← task definition "demo-app:7" (image, CPU/memory, env, logs, health check, roles)
                 └─ registered by IP in the ALB target group
```
| ECS | Kubernetes (Phase 5) |
|-----|----------------------|
| task definition | Pod spec |
| task | Pod |
| service | Deployment + Service |
| cluster | cluster (no control plane to run or pay for) |
| Fargate | serverless nodes: AWS runs the machine |

**Fargate** means there are no EC2 instances to patch or scale: you pay per task for vCPU and memory. The **EC2 launch
type** (your own instances, via capacity providers) is cheaper at large, steady scale.

## 📖 Lesson 6.3 — demo-app on Fargate with Terraform

[`terraform/`](solutions/terraform/) runs in the Module 03 VPC: the ALB sits in the public subnets and the tasks sit in
the private subnets with no public IP.

```bash
../03-networking-vpc/solutions/vpc_lab.sh       # ☁️ add --with-nat (or VPC endpoints) so tasks can pull from ECR
cd solutions/terraform && terraform init
terraform apply -var image=<account>.dkr.ecr.<region>.amazonaws.com/demo-app:sha-abc123
curl "$(terraform output -raw url)/health"; eval "$(terraform output -raw logs)"
terraform destroy -var image=x && ../../../03-networking-vpc/solutions/vpc_lab.sh --cleanup
```
On local AWS add `-var autoscaling=false`, because moto never finishes creating scaling targets. Everything else applies
and destroys there. Read [`main.tf`](solutions/terraform/main.tf) for:
- **Two roles.** `execution` has the managed ECS execution policy (pull from ECR, write logs). `task` starts empty: add
  only what demo-app needs, for example `dynamodb:UpdateItem` on one table (Module 05).
- **Hardened container.** It has a read-only root filesystem, runs as user 10001, has a container health check, and its
  logs go to CloudWatch with 14-day retention.
- **Safe deployments.** `minimum_healthy_percent = 100` starts new tasks before stopping old ones. The **deployment
  circuit breaker** rolls back a release that never becomes healthy, automatically.
- **Autoscaling.** CPU target tracking keeps between 2 and 6 tasks. `ignore_changes = [desired_count]` stops Terraform
  from fighting the autoscaler.

Deploying a new version means a new task definition revision plus updating the service. Terraform can do it
(`-var image=...:sha-new`), and so can the pipeline (`aws ecs update-service --force-new-deployment`, or
`aws-actions/amazon-ecs-deploy-task-definition`). The capstone does it from GitHub Actions.

## 📖 Lesson 6.4 — EKS, App Runner, Lambda: choosing

| Need | Choose |
|------|--------|
| Containers, simplest operations, AWS-only | **ECS Fargate** |
| The Kubernetes ecosystem (Helm, Argo CD, operators), multi-cloud skills, many teams | **EKS**: managed control plane (~$73/month) plus nodes (managed node groups, Karpenter or Fargate) |
| One web container, no networking to design | **App Runner** |
| Event-driven code that runs for seconds | **Lambda** (Module 07) |

EKS essentials, if you go that way:
- `aws eks update-kubeconfig --name <cluster>` connects kubectl.
- **EKS Pod Identity** (or IRSA) gives Pods AWS permissions without keys.
- The **AWS Load Balancer Controller** turns Ingress objects into ALBs.
- Phases 5 and 8 apply unchanged.
- Build it with the `terraform-aws-modules/eks` module and destroy it the same day.

---

## ⚠️ Common mistakes
- Mutable `latest` tags, so you can't know or roll back what's running
- Private tasks with no NAT or VPC endpoints, which fail with `CannotPullContainerError`
- Giving the **task** role the execution policy, or `AdministratorAccess`, "to make it work"
- Health check grace periods shorter than the app's start-up, so ECS kills healthy tasks in a loop
- No circuit breaker, so a broken release keeps replacing tasks forever
- Log groups without retention, and EKS clusters left running over the weekend

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Everything except image pushes and running tasks works on local AWS.

### Lab 1 ⭐⭐ — A registry done right
Write `ecr_push.sh`: create the repository with immutable tags, scan on push and KMS, plus the lifecycle policy. ☁️ Push
demo-app, then try to push the same tag again. What happens? Look at the scan findings.

### Lab 2 ⭐⭐ — Read a task definition
Register the task definition from the Terraform and run `aws ecs describe-task-definition --task-definition demo-app`.
For each field, say which Phase 4 `docker run` flag or Phase 5 Pod field it matches.

### Lab 3 ⭐⭐⭐ — demo-app on Fargate
Write the Terraform in `solutions/terraform/` and apply it against local AWS (`-var autoscaling=false`). ☁️ On real AWS:
- Open the URL.
- Tail the logs.
- Deploy a new image tag and watch the rolling deployment in `aws ecs describe-services`.
- Deploy an image that crashes and watch the circuit breaker roll it back.

### Lab 4 ⭐⭐⭐ — Least privilege for the app
Give demo-app's task role permission to update **only** the `demo-visits` DynamoDB table from Module 05. Check the policy
with `iam_audit.py` from Module 02.

---

## ✅ Checkpoint
- [ ] My images live in ECR with immutable tags, scanning and lifecycle rules
- [ ] I can run a service on ECS Fargate behind an ALB with Terraform
- [ ] I know the execution role from the task role and give each the minimum
- [ ] My deployments roll, roll back automatically and autoscale
- [ ] I can explain when to choose ECS, EKS, App Runner or Lambda

👉 Next: [Module 07 — Serverless & Monitoring](../07-serverless-and-monitoring/README.md)
