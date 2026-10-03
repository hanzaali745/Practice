# Terraform Module 10 — Terraform Capstone 🏆

> **CEO note:** Infrastructure code is reviewed more strictly than application code, because mistakes delete
> things. Your capstone must look like something a platform team would merge: modules, tests, CI, and no secrets.

**Definition of Done:**
- [ ] Reusable module(s) with typed, validated, documented inputs and useful outputs
- [ ] One root module per environment (separate state); providers configured with explicit contexts/regions
- [ ] `terraform test` covering the happy path **and** the guard rails (`expect_failures`)
- [ ] `fmt`, `validate`, `tflint` (and a security scanner) clean
- [ ] A CI workflow: checks + tests on every PR
- [ ] Remote state with locking for anything shared (S3 or similar); no state or secrets in Git
- [ ] A README with architecture, usage and a destroy section

---

## Project 1 ⭐⭐⭐ — The demo platform, as code (full reference solution)

Everything from the Kubernetes capstone, rebuilt as a **Terraform module** and deployed per environment:

```
platform/
├── modules/demo-platform/     # namespace (restricted) · quota · ConfigMap · Redis StatefulSet + PVC
│   ├── *.tf                   # demo-app Deployment (hardened, probes) · Service · Ingress · HPA · PDB
│   └── tests/                 # NetworkPolicies: default deny, traefik → app, app → redis
│       └── platform.tftest.hcl   ← 6 tests with a MOCKED Kubernetes provider (no cluster needed)
└── live/
    ├── dev/main.tf            # env = dev,  1–3 replicas, small quota
    └── prod/main.tf           # env = prod, 3–10 replicas, bigger quota and storage
```

👉 Reference: [`solutions/platform/`](solutions/platform/)

```bash
cd solutions/platform
./check.sh                                  # fmt + validate + 6 tests — works without a cluster
cd live/dev && terraform init && terraform apply          # needs the kind lab cluster + Traefik
curl http://demo-dev.localtest.me/visits
terraform apply -var app_version=1.1.0                    # rolling update through Terraform
```

**Stretch goals:** store state in a Kubernetes Secret backend (`backend "kubernetes"`) or S3 · add a GitHub Actions
workflow (Module 09) · expose `/metrics` and add a `ServiceMonitor` · add a `check` block that calls the app's `/health`.

---

## Project 2 ⭐⭐⭐ — AWS web tier (needs AWS; use the free tier and destroy daily)
Modules `network` (VPC, 2 public + 2 private subnets across AZs) and `web` (security groups, launch template with
cloud-init, Auto Scaling Group of 2, Application Load Balancer). Remote state in S3 with locking. Output the ALB URL.
**Cost warning:** ALBs are not free — run it, test it, `terraform destroy` the same day.

## Project 3 ⭐⭐ — GitHub as code
Use the `integrations/github` provider to manage your own GitHub repositories, branch protection rules and team
access with `for_each` over a map. Import your existing `Practice` repo with an `import` block.

## Project 4 ⭐⭐⭐ — Terraform + Ansible handoff
Terraform creates servers (on AWS, or "servers" as Docker containers via a provider) and writes an Ansible inventory
with `templatefile` (Module 05). Ansible (next phase!) then configures them. This is the classic
**provision with Terraform, configure with Ansible** pattern.

---

## 🎓 Terraform phase complete!
Tick the [Terraform expert checklist](../README.md#-terraform-expert-checklist), then move on to the last phase.

👉 Next phase: [Phase 7 — Ansible](../../7-ansible/README.md)
