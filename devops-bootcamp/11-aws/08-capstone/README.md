# AWS Module 08 — AWS Capstone: demo-app on AWS, end to end 🏆

## 🎯 The goal
Take the lab repo from Phase 8 and run it on AWS the way a real team would:

```
git push ─► GitHub Actions ─(OIDC, no keys)─► ECR (immutable tag, scanned) ─► ECS Fargate rollout ─► smoke test
                                                                               │
 internet ─► ALB (public subnets, 2 AZs) ─► demo-app tasks (private subnets) ──┴─► CloudWatch Logs
                                                                                   │
                         CloudWatch alarms (5xx, p99, unhealthy, too few tasks, error logs) ─► SNS ─► you
```
All infrastructure is Terraform: reviewed, tested (`terraform test`), and owned by code. Everything you built in this
phase comes together here:
- IAM roles and OIDC (Module 02)
- the VPC (03)
- the ALB and autoscaling (04)
- the storage habits (05)
- ECR and ECS (06)
- CloudWatch and SNS (07)

…on top of Phases 4 (image), 6 (Terraform), 8 (pipeline) and 9 (alerting with runbooks).

## 📦 What's in [`solutions/`](solutions/)
| Path | What |
|------|------|
| [`infra/`](solutions/infra/) | Terraform root: ECR + [`modules/network`](solutions/infra/modules/network/main.tf) + [`modules/service`](solutions/infra/modules/service/main.tf) + [`alarms.tf`](solutions/infra/alarms.tf) + [`github_oidc.tf`](solutions/infra/github_oidc.tf) |
| [`infra/tests/`](solutions/infra/tests/capstone.tftest.hcl) | `terraform test` with a **mocked AWS provider**: 6 safety checks in seconds, no account needed |
| [`pipeline/.github/workflows/deploy-aws.yml`](solutions/pipeline/.github/workflows/deploy-aws.yml) | CI → OIDC → build · Trivy · push → `ecs_deploy.sh` → smoke test, in the `production` environment |
| [`pipeline/scripts/ecs_deploy.sh`](solutions/pipeline/scripts/ecs_deploy.sh) | new task definition revision → update service → wait → **detect circuit-breaker rollbacks** |
| [`pipeline/docs/runbook.md`](solutions/pipeline/docs/runbook.md) | what to do for each alarm (every alarm links to it) |
| [`bootstrap_state.sh`](solutions/bootstrap_state.sh) | S3 bucket for remote state: private, versioned, encrypted, TLS only |
| [`install_into.sh`](solutions/install_into.sh) | copies all of it into your lab repo as one commit |
| [`check.sh`](solutions/check.sh) | the capstone's quality gate; `--local-aws` also applies, deploys and destroys on local AWS |

---

## 🛠️ Build it

### Step 1 — Rehearse locally (free)
```bash
cd solutions
./check.sh                                   # fmt · validate · terraform test · actionlint · zizmor · pins · shellcheck
docker compose -f ../../local-aws/compose.yaml up -d && source ../../local-aws/env.sh
./check.sh --local-aws                       # + apply the whole stack, roll out revision 2, destroy
source ../../local-aws/env.sh off
```
Local AWS can't run containers, and moto can't create alarms or autoscaling through Terraform. So `--local-aws`
turns those two off, and checks that the rollout *starts* rather than waiting for healthy tasks.

### Step 2 — ☁️ Infrastructure on real AWS
Use your sandbox account from Module 01, with its budget alarm. Then:
```bash
./bootstrap_state.sh                         # state bucket; then uncomment the backend "s3" block in infra/versions.tf
./install_into.sh ~/cicd-lab && cd ~/cicd-lab/infra
terraform init
terraform apply -target=aws_ecr_repository.app -var image_tag=bootstrap -var github_repo=<you>/cicd-lab
```
`-target` is for bootstrapping only: the service can't start until its first image exists.

### Step 3 — The first image, then everything else
```bash
repo=$(terraform output -raw ecr_repository_url); tag=sha-$(git rev-parse --short=7 HEAD)
aws ecr get-login-password | docker login --username AWS --password-stdin "${repo%%/*}"
docker build --build-arg VERSION="$tag" -t "$repo:$tag" .. && docker push "$repo:$tag"
terraform apply -var image_tag="$tag" -var github_repo=<you>/cicd-lab -var alert_email=<you@example.com>
curl "$(terraform output -raw url)/"        # {"version": "sha-…"} — through the ALB, from a private task
```
Confirm the SNS subscription email.

### Step 4 — Hand deployments to the pipeline
```bash
terraform output -json github_variables | jq -r 'to_entries[] | "gh variable set \(.key) --body \(.value)"' | sh
```
In the repo's **Settings → Environments → production**, add yourself as a required reviewer. Then push a change
(edit the `/` message) and approve the deployment. The workflow:
1. assumes the role through OIDC (no secrets in GitHub)
2. builds, scans and pushes `sha-<commit>`
3. registers a new task definition **by digest** and rolls it out
4. waits for health checks and runs the smoke test through the ALB

Terraform never fights the pipeline, because the service has `ignore_changes = [task_definition, desired_count]`.

### Step 5 — Prove it works under failure
| Experiment | Expected |
|------------|----------|
| Push a commit whose app crashes on start | ECS circuit breaker rolls back; `ecs_deploy.sh` fails the run; the old version keeps serving |
| `aws ecs stop-task` on one task | ALB keeps serving from the other AZ; ECS replaces the task |
| Hammer `/work?ms=500` (Phase 9 `loadgen.py`) | CPU rises → autoscaling adds tasks (up to 6) → p99 alarm maybe fires → scales back in |
| Hammer `/error` | `5xx-errors` and `error-logs` alarms → email with the runbook link → OK email afterwards |
| Re-run an old successful workflow run | that commit's image is redeployed: a rollback with one click |
| Try to assume the deploy role from a branch build without the environment | denied: the trust policy only accepts `environment:production` |

### Step 6 — Tear down (the same day!)
```bash
terraform destroy -var image_tag=x -var github_repo=<you>/cicd-lab
```
ECR refuses to delete a repository with images: delete them first, or set `force_delete = true` in a lab. Keep the
state bucket; it costs cents. Check **Billing → Bills** the next day.

## 💰 What it costs (eu-west-1, approximately)
| Resource | Per day |
|----------|---------|
| ALB | ~$0.60 + traffic |
| NAT gateway | ~$1.10 + $0.05/GB (lab mode `-var nat_gateway=false` skips it) |
| 2 Fargate tasks (0.25 vCPU, 0.5 GB) | ~$0.60 |
| Public IPv4 addresses | $0.12 each (ALB nodes; tasks too in lab mode) |
| CloudWatch, ECR, S3, SNS | cents |
| **Total** | **~$2.50/day**, or ~$1.50 in lab mode. **Not** free tier. Destroy it when you're done |

---

## 🎓 Certification prep
This phase covers most of these exams:

| Exam | Level | Focus |
|------|-------|-------|
| **AWS Certified Cloud Practitioner** (CLF) | foundational | Modules 01, 02, 05: services, pricing, shared responsibility |
| **AWS Certified Solutions Architect – Associate** (SAA) | associate | Modules 03–07: VPC design, HA across AZs, storage choice, decoupling |
| **AWS Certified DevOps Engineer – Professional** (DOP) | professional | this capstone + Phase 8: CI/CD, IaC, monitoring, incident response, deployment strategies |

How to study:
1. Start with SAA.
2. Build first, then read the AWS *Well-Architected Framework* (its six pillars map onto this capstone).
3. Do one official practice exam per domain.
4. For every question you get wrong, find the service in your own Terraform.

## ⭐ Stretch goals
- **HTTPS**: a Route 53 domain + ACM certificate, a 443 listener and an HTTP → HTTPS redirect
- **Secrets**: an RDS database (Module 05) whose password reaches the task through the `secrets` block of the container
  definition (Secrets Manager); extend the execution role for it
- **Cheaper egress**: replace the NAT gateway with VPC endpoints (ECR API + DKR, S3 gateway, CloudWatch Logs)
- **Staging first**: a second workspace or stack for `staging`; deploy there automatically, promote the same digest
  to production after approval (the Phase 8 pattern)
- **Blue/green**: switch to an ECS **blue/green deployment** with two target groups and a test listener
- **Drift detection**: a nightly workflow running `terraform plan -detailed-exitcode` that opens an issue on drift
- **Security baseline**: CloudTrail, GuardDuty and Security Hub in Terraform (Module 07, Lesson 7.5)

---

## ✅ Done when
- [ ] `./check.sh` passes, and `./check.sh --local-aws` passes on local AWS
- [ ] ☁️ A push to `main` deploys to ECS after approval, with no AWS keys stored in GitHub
- [ ] ☁️ A broken release is rolled back automatically and the workflow run turns red
- [ ] ☁️ An alarm reached my inbox with a runbook link, and so did the OK message
- [ ] I can explain every resource in `infra/`: why it exists and what it costs
- [ ] ☁️ Everything is destroyed, and the bill shows what I expected

🎉 **That's the AWS track — and the whole bootcamp.** Go back to the
[AWS expert checklist](../README.md#-aws-expert-checklist), then the [bootcamp README](../../README.md) for what's next.
