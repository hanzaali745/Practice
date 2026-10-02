# Terraform Module 03 — Variables, Outputs & Locals 🟡

## 🎯 Objectives
- Make configurations reusable with **input variables** (types, defaults, descriptions)
- Validate input with `validation` blocks
- Set values with `.tfvars` files, `-var` and `TF_VAR_` environment variables (and know the precedence)
- Expose results with **outputs**; hide secrets with `sensitive`
- Keep code DRY with **locals**

## 🧠 Why DevOps engineers care
The same configuration must build dev, staging and prod with different sizes, names and counts. Variables are
the "function parameters" of Terraform, outputs are its "return values", and locals are its "helper
variables". Good variable design is the difference between reusable infrastructure and copy-paste chaos.

---

## 📖 Lesson 3.1 — Input variables

`variables.tf`:
```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  # no default → REQUIRED: Terraform asks for it, or fails in CI
}

variable "replicas" {
  description = "Number of app instances"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = { team = "platform" }
}

variable "database" {
  type = object({
    engine  = string
    size_gb = number
    backup  = optional(bool, true)     # optional attribute with a default
  })
  default = { engine = "postgres", size_gb = 10 }
}
```
Use them as `var.environment`, `var.tags["team"]`, `var.database.size_gb`.

## 📖 Lesson 3.2 — Validation

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "replicas" {
  type    = number
  default = 1
  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10 && floor(var.replicas) == var.replicas
    error_message = "replicas must be a whole number from 1 to 10."
  }
}
```
Bad values fail at `plan` time with your message — long before anything is built.

## 📖 Lesson 3.3 — Setting values (and precedence)

From lowest to highest priority (later wins):

1. `default` in the variable block
2. `TF_VAR_<name>` environment variables — `export TF_VAR_environment=dev`
3. `terraform.tfvars` and `*.auto.tfvars` (loaded automatically)
4. `-var-file=prod.tfvars`
5. `-var 'replicas=3'` on the command line

The usual pattern — one file per environment:
```
dev.tfvars:   environment = "dev"   replicas = 1
prod.tfvars:  environment = "prod"  replicas = 3   enable_monitoring = true
```
```bash
terraform plan -var-file=dev.tfvars
terraform plan -var-file=prod.tfvars
```

> 🔐 Secrets: pass them with `TF_VAR_db_password` from your CI's secret store — never in `.tfvars` in Git.

## 📖 Lesson 3.4 — Sensitive values

```hcl
variable "db_password" {
  type      = string
  sensitive = true          # shown as (sensitive value) in plan/apply output
}
```
⚠️ `sensitive` hides values in the **terminal only**. They are still stored in plain text in the **state
file** — which is why state must be protected (Module 04).

## 📖 Lesson 3.5 — Locals

Locals are named expressions — compute something once, use it everywhere:
```hcl
locals {
  name_prefix = "demo-${var.environment}"
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })
  is_prod = var.environment == "prod"
  replicas = local.is_prod ? max(var.replicas, 3) : var.replicas   # prod gets at least 3
}
```
Use them as `local.name_prefix` (note: `local.`, singular). Rule of thumb: **variables** are inputs users
set; **locals** are internal values users shouldn't touch.

## 📖 Lesson 3.6 — Outputs

```hcl
output "config_file" {
  description = "Path of the generated config"
  value       = local_file.config.filename
}

output "summary" {
  value = {
    environment = var.environment
    replicas    = local.replicas
  }
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}
```
```bash
terraform output                      # all outputs
terraform output -raw config_file     # just the value (great in scripts)
terraform output -json | jq .summary.value
```
Outputs are also how **modules** return values (Module 06) and how other tools (Ansible, CI) read Terraform's results.

## 📖 Lesson 3.7 — File layout convention

```
main.tf          # resources
variables.tf     # variable blocks
outputs.tf       # output blocks
versions.tf      # terraform {} block with required_version + providers
locals.tf        # (optional) locals
dev.tfvars, prod.tfvars
```
Terraform reads every `.tf` file in the folder — the split is just for humans.

## 📖 Lesson 3.8 — Experiment in `terraform console`

```bash
terraform console -var-file=prod.tfvars
> local.name_prefix
"demo-prod"
> local.common_tags
> upper(var.environment)
```

---

## ⚠️ Common mistakes
- Variables without `type` and `description`
- Thinking `sensitive = true` encrypts anything (state still has the value)
- Secrets in `.tfvars` committed to Git
- Huge "god variables" (one object with 50 fields) — keep variables focused
- `var.` vs `local.` vs `locals {}` mix-ups

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — try `terraform plan -var-file=dev.tfvars` and `prod.tfvars`.

### Lab 1 ⭐ — Parameterise
Turn the Module 01 Lab 2 config into a parameterised one: `environment` (required, validated), `app_port`
(number, 1024–65535), `log_level` (one of debug/info/warn/error), generating `out/<env>/app.conf`.

### Lab 2 ⭐⭐ — Environments with tfvars
Create `dev.tfvars` and `prod.tfvars`. Prod must get at least 3 replicas even if the tfvars says 1 (use a
local). Show the different plans. Try an invalid environment and read your validation message.

### Lab 3 ⭐⭐ — Secrets the right way
Add a sensitive `db_password` variable with no default, provided via `TF_VAR_db_password`. Write it into a
`local_sensitive_file`. Show it's hidden in output but present in `terraform.tfstate` (`grep` it) — then
delete that state file and remember why remote encrypted state matters.

### Lab 4 ⭐⭐ — Outputs for other tools
Output a `summary` object and use `terraform output -json | jq` in a small Bash script that prints
"Environment X runs N replicas on port P". This is how pipelines pass Terraform results to the next step.

---

## ✅ Checkpoint
- [ ] I write typed, described, validated variables
- [ ] I know the variable precedence order and use per-environment tfvars
- [ ] I know `sensitive` doesn't protect state
- [ ] I use locals for derived values and outputs to hand data to other tools

👉 Next: [Module 04 — State](../04-state/README.md)
