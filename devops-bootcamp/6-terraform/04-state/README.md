# Terraform Module 04 — State 🟡

## 🎯 Objectives
- Understand what the state file is and why Terraform needs it
- Inspect state safely (`state list`, `state show`, `show`)
- Refactor without destroying anything: `moved` blocks
- Bring existing resources under Terraform with `import` blocks; let go with `removed` blocks
- Detect **drift** with `plan -refresh-only`
- Store state remotely with **locking** (S3 backend); use workspaces

## 🧠 Why DevOps engineers care
State is Terraform's memory of what it built. Lose it and Terraform forgets your infrastructure; let two
people write it at once and it corrupts; leave it unencrypted and you leak every password in it. Most
serious Terraform incidents are state incidents — and refactoring/importing are everyday senior tasks.

---

## 📖 Lesson 4.1 — What state is

`terraform.tfstate` is a JSON file mapping **your code** to **real objects**:

```
 code: random_string.suffix      ⇄   state: id = "x7k2p9", length = 6, result = "x7k2p9"   ⇄   reality
```

Terraform uses it to: know what it manages, compute diffs quickly, track dependencies for deletion, and
store attributes that can't be read back. **Never edit it by hand.**

```bash
terraform state list                      # every resource address in state
terraform state show random_string.suffix # one resource's attributes
terraform show                            # everything, human-readable
terraform show -json | jq '.values.root_module.resources[].address'
```

## 📖 Lesson 4.2 — Refactoring with `moved` blocks

Renaming a resource in code normally means **destroy + create** (Terraform thinks the old one was removed
and a new one added). A `moved` block says "same object, new address":

```hcl
resource "random_string" "app_suffix" {       # was: random_string.suffix
  length  = 6
  special = false
}

moved {
  from = random_string.suffix
  to   = random_string.app_suffix
}
```
`terraform plan` → `# random_string.suffix has moved to random_string.app_suffix` and **0 to destroy**.
The same works for moving resources into modules (`to = module.app.random_string.suffix`) and for
`count` → `for_each` changes. (The older CLI way: `terraform state mv`.)

## 📖 Lesson 4.3 — Importing existing infrastructure

Something was created by hand (or by another tool) and you want Terraform to manage it — without
recreating it:

```hcl
import {
  to = random_string.legacy
  id = "abc123"                 # the provider's ID for the existing object
}

resource "random_string" "legacy" {
  length = 6
}
```
```bash
terraform plan            # must say: 1 to import, 0 to add, 0 to change, 0 to destroy
terraform apply
```

> ⚠️ If the plan says "1 to import **and** 1 to destroy", your resource block doesn't match the real
> object, and Terraform would **replace** what you just imported. (For example, adding `special = false`
> here — the real value `abc123` was imported with the default `special = true`.) Fix the code until the
> plan shows only the import.
Even better: let Terraform **write the code** for you:
```bash
terraform plan -generate-config-out=generated.tf     # with only the import block present
```
In real life: `import { to = aws_s3_bucket.logs  id = "my-company-logs" }`.

## 📖 Lesson 4.4 — Letting go with `removed` blocks

Stop managing a resource **without destroying it** (e.g. handing it to another team's config):
```hcl
removed {
  from = random_string.legacy
  lifecycle {
    destroy = false             # forget it, leave the real object alone
  }
}
```
(The older CLI way: `terraform state rm`.)

## 📖 Lesson 4.5 — Drift

Someone changed things outside Terraform ("just a quick fix in the console")? Find out:
```bash
terraform plan -refresh-only        # shows what changed in reality vs state, proposes no infra changes
terraform apply -refresh-only       # accept reality into state
terraform plan                      # then: does the code still match? Fix code or let Terraform revert the drift
```
Run a scheduled `plan` in CI to detect drift early (`-detailed-exitcode` → exit 2 when there are changes).

## 📖 Lesson 4.6 — Remote state and locking

Local state breaks as soon as there's a team: two laptops, two different states, no locking. Use a
**remote backend**. On AWS, S3 (Terraform 1.10+ can lock with an S3 lock file — no DynamoDB needed):

```hcl
terraform {
  backend "s3" {
    bucket       = "acme-terraform-state"
    key          = "demo/prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true            # encrypted at rest
    use_lockfile = true            # locking: a second `apply` waits/fails instead of corrupting state
  }
}
```
```bash
terraform init -migrate-state      # move existing local state into the backend
```
Other backends: Azure Storage (`azurerm`), Google Cloud Storage (`gcs`), Kubernetes Secret
(`kubernetes`), HCP Terraform / Terraform Enterprise, PostgreSQL (`pg`).

Protect the state bucket like a password vault: versioning on, encryption, very limited IAM access, never public.

If a lock gets stuck (a crashed CI job): `terraform force-unlock <LOCK_ID>` — only when you're **sure**
nothing is running.

## 📖 Lesson 4.7 — Workspaces

One configuration, several independent states:
```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
terraform workspace list
```
```hcl
locals {
  env = terraform.workspace          # "dev" / "prod"
}
```
Workspaces suit **short-lived or identical** environments (feature-branch previews). For dev/prod with
different settings, accounts and permissions, most teams prefer **separate directories or root modules per
environment** (Module 06/10) — it's harder to apply to prod by accident.

---

## ⚠️ Common mistakes
- Committing state to Git; storing it unencrypted; making the state bucket public
- Renaming resources without `moved` → surprise destroy/create in the plan
- `terraform state rm` / `force-unlock` without understanding what happens
- Team members each running Terraform with local state
- Treating "1 to destroy" in a plan as normal when you only renamed something — **stop and check**

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `lab_state.sh` walks through every lab and checks the results.

### Lab 1 ⭐ — Explore state
Apply a config with a `random_string` and a `local_file`. Use `state list`, `state show` and
`show -json | jq` to find the random value. Open `terraform.tfstate` in an editor and look (don't edit!).

### Lab 2 ⭐⭐ — Rename safely
Rename `random_string.suffix` to `random_string.app_suffix`. First **without** a `moved` block — read the
plan (destroy + create!). Then add the `moved` block and see "has moved" with nothing destroyed.

### Lab 3 ⭐⭐ — Import and remove
Import an existing value `abc123` as `random_string.legacy` with an `import` block. Then stop managing it with a
`removed` block (`destroy = false`) and show it's gone from `state list`.

### Lab 4 ⭐⭐ — Drift and workspaces
Delete the managed file by hand and run `plan -refresh-only`. Then create `dev` and `prod` workspaces whose
files are named after `terraform.workspace`, apply both, and show the two separate state files under
`terraform.tfstate.d/`.

---

## ✅ Checkpoint
- [ ] I can explain what state stores and why it must be protected
- [ ] I use `moved` for refactors and `import`/`removed` blocks instead of hand-editing state
- [ ] I can detect drift with `-refresh-only`
- [ ] I know how a remote backend with locking works, and workspaces vs separate directories

👉 Next: [Module 05 — Expressions, Loops & Functions](../05-expressions-and-loops/README.md)
