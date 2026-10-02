# Terraform Module 06 — Modules 🔴

## 🎯 Objectives
- Package reusable infrastructure as a **module** with inputs and outputs
- Call the same module for dev and prod (one root configuration per environment)
- Use modules from the Terraform Registry and from Git, **pinned to versions**
- Structure a real Terraform repository
- Move existing resources into a module without destroying them

## 🧠 Why DevOps engineers care
Modules are Terraform's functions. Your platform team writes a `webapp` or `vpc` module once, with security
and tagging built in, and every team uses it. Consistency, less code, and fixes in one place. Reading and
writing modules is expected of any engineer working with Terraform.

---

## 📖 Lesson 6.1 — Every folder is a module

The folder you run `terraform` in is the **root module**. A **child module** is just another folder of `.tf`
files that you call:

```
modules/
└── webapp/                  # the child module
    ├── main.tf
    ├── variables.tf         # its inputs
    ├── outputs.tf           # its return values
    ├── versions.tf          # required providers (no provider config here!)
    └── README.md
envs/
├── dev/main.tf              # root module for dev  → calls ../../modules/webapp
└── prod/main.tf             # root module for prod → calls ../../modules/webapp
```

## 📖 Lesson 6.2 — Calling a module

`envs/dev/main.tf`:
```hcl
module "web" {
  source = "../../modules/webapp"      # local path (or Git/registry — Lesson 6.4)

  name        = "shop"                 # inputs = the module's variables
  environment = "dev"
  replicas    = 1
  port        = 8000
}

output "web_config" {
  value = module.web.config_file       # outputs = module.<NAME>.<OUTPUT>
}
```
After adding or changing a module `source`, run `terraform init` again.

You can call a module many times:
```hcl
module "web" {
  source   = "../../modules/webapp"
  for_each = toset(["shop", "blog", "api"])
  name        = each.key
  environment = "dev"
}
```

## 📖 Lesson 6.3 — Designing a good module

Inside `modules/webapp/variables.tf` — a clear, typed, validated interface:
```hcl
variable "name" {
  description = "Application name (lowercase, used in file and resource names)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.name))
    error_message = "name must be lowercase letters, digits and dashes."
  }
}
```

Rules of thumb:
- **Small and focused** — "a web app", "a VPC", not "the whole company"
- Inputs have types, descriptions, validation and **safe defaults** (secure by default)
- **No `provider` blocks** inside reusable modules — the caller configures providers
- Output everything a caller might need (IDs, names, endpoints)
- A `README.md` with an example; generated docs with `terraform-docs`
- Don't wrap a single resource in a module "just because"

## 📖 Lesson 6.4 — Modules from the Registry and Git

**Terraform Registry** (registry.terraform.io) — thousands of community modules:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"                    # ALWAYS pin registry modules

  name = "demo"
  cidr = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

**Git** — your company's own modules, pinned to a tag:
```hcl
module "web" {
  source = "git::https://github.com/acme/terraform-modules.git//webapp?ref=v1.4.0"
}
```
`//webapp` = a sub-folder in the repo, `?ref=v1.4.0` = a tag (never a moving branch in prod).

## 📖 Lesson 6.5 — One root module per environment

```
envs/dev/main.tf     → module "web" { environment = "dev",  replicas = 1 }  + backend key dev/terraform.tfstate
envs/prod/main.tf    → module "web" { environment = "prod", replicas = 3 }  + backend key prod/terraform.tfstate
```
- Separate state per environment (a bad dev apply can't touch prod)
- Different permissions per environment folder in CI
- Promote changes: bump the module version in dev, test, then in prod

## 📖 Lesson 6.6 — Refactoring into a module without destroying

You had `resource "local_file" "config"` in the root and moved it into the module. Tell Terraform:
```hcl
moved {
  from = local_file.config
  to   = module.web.local_file.config
}
```
Plan shows "has moved", nothing destroyed — Module 04's `moved` block again.

---

## ⚠️ Common mistakes
- Registry/Git modules without a version → surprise changes
- `provider` blocks inside reusable modules
- Modules with 40 inputs that just re-expose every argument — no real abstraction
- Forgetting `terraform init` after changing a module source
- One giant root module for every environment (huge blast radius, slow plans)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `./check.sh` applies dev and prod and shows the differences.

### Lab 1 ⭐⭐ — Write the `webapp` module
Create `modules/webapp` that generates, for an app: `<out_dir>/<name>-<env>/app.conf`, an nginx `site.conf` (with
`replicas` upstream servers on consecutive ports), and a `README.md`. Inputs: `name` (validated), `environment`
(validated), `port` (default 8000), `replicas` (default 1), `out_dir`. Outputs: `config_file`, `app_dir`, `ports`.

### Lab 2 ⭐⭐ — dev and prod roots
Create `envs/dev` and `envs/prod` calling the module with different settings, each with its own state. Apply both and
compare the generated files.

### Lab 3 ⭐⭐ — Many apps
In dev, call the module with `for_each` for `shop`, `blog` and `api` with different ports. Output a map of app → port.

### Lab 4 ⭐⭐⭐ — Refactor safely
Start from a root config that has a plain `local_file` resource. Move it into a module call and add a `moved` block so
that `terraform plan` shows the file **has moved** and **0 to destroy** (the module's extra files — `site.conf`,
`README.md` — are the only additions).

---

## ✅ Checkpoint
- [ ] I can write a module with typed, validated inputs and useful outputs
- [ ] I call modules from local paths, Git (with `ref`) and the Registry (with `version`)
- [ ] I use one root module (and state) per environment
- [ ] I can move resources into modules with `moved` blocks

👉 Next: [Module 07 — Terraform + Kubernetes](../07-kubernetes-with-terraform/README.md)
