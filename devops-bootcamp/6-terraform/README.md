# 🏗️ Phase 6: Terraform

> **Before you start:** finish Phases 4–5 and install Terraform ([Part 2 of the Ubuntu setup](../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md)).
> **It's free:** Modules 01–07 and 09–10 only use local providers (files, random values) and your kind cluster.
> Only Module 08 (optional) uses AWS — with clear cost and safety rules.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [IaC & Your First Config](01-iac-and-first-config/README.md) | 🟢 | init/plan/apply/destroy, HCL basics, Git hygiene |
| 02 | [Resources & Dependencies](02-resources-and-dependencies/README.md) | 🟢 | references, the graph, data sources, lifecycle |
| 03 | [Variables, Outputs & Locals](03-variables-outputs-locals/README.md) | 🟡 | typed/validated inputs, tfvars per environment, outputs |
| 04 | [State](04-state/README.md) | 🟡 | moved/import/removed blocks, drift, remote state + locking |
| 05 | [Expressions, Loops & Functions](05-expressions-and-loops/README.md) | 🔴 | for_each vs count, for expressions, templatefile, dynamic |
| 06 | [Modules](06-modules/README.md) | 🔴 | write/call/version modules, one root per environment |
| 07 | [Terraform + Kubernetes](07-kubernetes-with-terraform/README.md) | 🔴 | manage your kind cluster with the Kubernetes provider |
| 08 | [Terraform on AWS (optional)](08-aws-with-terraform/README.md) | 🔴 | safe account, VPC + EC2, S3 remote state |
| 09 | [Workflow, Testing & CI](09-workflow-testing-ci/README.md) | 🔴 | tflint, `terraform test`, mocks, PR pipelines |
| 10 | [Terraform Capstone](10-capstone/README.md) | 🏆 | the demo platform as tested, multi-environment code |

## Terraform cheat sheet

```bash
terraform init [-upgrade] [-backend=false] [-migrate-state]
terraform fmt -recursive [-check]        terraform validate
terraform plan [-var-file=prod.tfvars] [-out=tfplan] [-refresh-only]
terraform apply [tfplan] [-replace=ADDR] [-auto-approve]
terraform destroy
terraform state list | state show ADDR   terraform show [-json]
terraform output [-raw NAME] [-json]     terraform console
terraform workspace list|new|select      terraform test
terraform plan -generate-config-out=generated.tf     # with an import block
```

```hcl
resource "TYPE" "NAME" { ... }           data "TYPE" "NAME" { ... }
variable "x" { type = string  validation { condition = ...  error_message = "..." } }
output "x" { value = ...  sensitive = true }
locals { a = ... }                       module "m" { source = "./modules/m"  version = "~> 1.0" }
for_each = var.map   count = var.on ? 1 : 0   [for k, v in var.m : v.x if v.y]
moved { from = A  to = B }   import { to = A  id = "..." }   removed { from = A  lifecycle { destroy = false } }
lifecycle { prevent_destroy = true  create_before_destroy = true  ignore_changes = [...] }
```

## 🏅 Terraform expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain providers, resources, state and the plan, and read any plan output confidently
- [ ] Write typed, validated variables, per-environment tfvars, locals and outputs
- [ ] Choose `for_each` over `count` and explain the "count trap"
- [ ] Refactor with `moved`, adopt with `import` (plan shows only the import!), let go with `removed`
- [ ] Detect drift with `-refresh-only` and protect critical resources with `lifecycle`
- [ ] Set up remote state with encryption, versioning and locking — and never commit state
- [ ] Write reusable modules with good interfaces; one root module per environment
- [ ] Manage Kubernetes (and, optionally, AWS) resources with explicit provider contexts/regions
- [ ] Test modules with `terraform test`, `expect_failures` and mock providers
- [ ] Describe and build a PR pipeline: checks, plan on PR, reviewed plan file, approved apply, OIDC

👉 Start: [Module 01 — IaC & Your First Config](01-iac-and-first-config/README.md)
