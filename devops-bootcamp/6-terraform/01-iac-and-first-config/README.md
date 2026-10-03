# Terraform Module 01 — Infrastructure as Code & Your First Config 🟢

## 🎯 Objectives
- Explain Infrastructure as Code (IaC) and why it beats clicking in consoles
- Understand how Terraform works: providers, resources, state, plan/apply
- Run the core workflow: `init` → `plan` → `apply` → `destroy`
- Read and write basic HCL (Terraform's language)
- Know what to commit to Git (and what never to commit)

## 🧠 Why DevOps engineers care
Servers, networks, databases, DNS, Kubernetes clusters, IAM users — all of it can be created by code that
is reviewed, versioned and repeatable. "Rebuild production in a new region" becomes running one command.
Terraform is the most widely used IaC tool, and it's in almost every DevOps job description.

> **Cost note:** Modules 01–07 and 09–10 use **local** providers (files, random values, your kind cluster) —
> completely free, nothing in the cloud. Only Module 08 (optional) touches AWS.

---

## 📖 Lesson 1.1 — What is Infrastructure as Code?

| Click-ops (manual) | Infrastructure as Code |
|--------------------|------------------------|
| someone clicks in the AWS console | infrastructure is described in files |
| "who changed this, and why?" — nobody knows | every change is a reviewed Git commit |
| staging and prod slowly drift apart | the same code builds every environment |
| disaster recovery = panic | disaster recovery = `terraform apply` |

Terraform is **declarative**, like Kubernetes: you describe the end state, Terraform works out the steps.

## 📖 Lesson 1.2 — How Terraform works

```
  your .tf files ──┐
                   ├──► terraform plan  ──► "I will create 2, change 1, destroy 0"
  terraform.tfstate┘         │
  (what exists)              ▼
                       terraform apply  ──► calls the PROVIDER's API ──► AWS / Kubernetes / GitHub / local files
                             │
                             └──► updates terraform.tfstate
```

| Word | Meaning |
|------|---------|
| **Provider** | a plugin that talks to one API (aws, kubernetes, github, local, random...) — 3,000+ exist |
| **Resource** | one thing to manage (`aws_instance`, `kubernetes_namespace_v1`, `local_file`) |
| **State** | Terraform's record of what it created (`terraform.tfstate`) — Module 04 |
| **Plan** | the diff between your code and reality, shown **before** anything changes |

## 📖 Lesson 1.3 — Your first configuration

```bash
mkdir -p ~/Practice/devops-bootcamp/my-work/terraform/01-hello && cd $_
```

`main.tf`:
```hcl
terraform {
  required_version = ">= 1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"      # registry.terraform.io/hashicorp/local
      version = "~> 2.5"               # any 2.x from 2.5 up — not 3.0
    }
  }
}

resource "local_file" "hello" {        # resource "<TYPE>" "<NAME>"
  filename = "${path.module}/hello.txt"
  content  = "Hello from Terraform!\n"
}
```

## 📖 Lesson 1.4 — The workflow

```bash
terraform init        # download providers into .terraform/, create .terraform.lock.hcl
terraform fmt         # format your code (always run before committing)
terraform validate    # check syntax and types
terraform plan        # SHOW what would change — read it every time!
terraform apply       # show the plan again, ask "yes", then make the changes
cat hello.txt
terraform destroy     # remove everything this config manages
```

Plan symbols:
```
  + create      ~ update in place      - destroy      -/+ destroy and re-create (replace)
```

Now edit the `content`, run `terraform plan`, and read it: `~ content = "Hello..." -> "Hi..."`.
(For `local_file`, a content change is actually `-/+` replace — the plan tells you exactly what will happen.)

Delete `hello.txt` by hand and run `terraform plan` — Terraform notices the **drift** and plans to create it again.

## 📖 Lesson 1.5 — HCL basics

```hcl
# Comment (also // and /* */)
resource "local_file" "config" {
  filename        = "app.conf"                          # string
  file_permission = "0640"
  content = <<-EOT                                       # heredoc for multi-line strings
    environment = dev
    replicas    = ${2 + 1}
  EOT
}

output "config_path" {                                   # print a value after apply
  value = local_file.config.filename                     # reference: TYPE.NAME.ATTRIBUTE
}
```

Types: `string`, `number`, `bool`, `list(...)`, `map(...)`, `object({...})`. Interpolation: `"${var}"`.

## 📖 Lesson 1.6 — Files in a Terraform project

| File | Commit to Git? |
|------|----------------|
| `*.tf` | ✅ yes — your code |
| `.terraform.lock.hcl` | ✅ **yes** — pins exact provider versions for everyone |
| `.terraform/` | ❌ no — downloaded plugins |
| `terraform.tfstate`, `*.tfstate.backup` | ❌ **never** — can contain secrets; use remote state (Module 04) |
| `*.tfvars` with secrets | ❌ no |

`.gitignore`:
```
.terraform/
*.tfstate
*.tfstate.*
crash.log
*.tfvars
!example.tfvars
```

---

## ⚠️ Common mistakes
- Running `apply` without reading the plan
- Committing `terraform.tfstate` (secrets!) or forgetting `.terraform.lock.hcl`
- Editing infrastructure by hand after Terraform created it → drift
- No version constraints → a new provider major version breaks you one morning

---

## 🧪 Labs
Work in `my-work/terraform/`. Solutions: [`solutions/`](solutions/) — each folder runs with
`terraform init && terraform apply`.

### Lab 1 ⭐ — Hello Terraform
Create `hello.txt` with `local_file`. Run the full workflow. Change the content and read the plan. Delete the
file by hand and see Terraform detect it. Finish with `destroy`.

### Lab 2 ⭐ — Several resources
Create a folder structure for a fake app with three `local_file` resources: `app/config/app.conf`,
`app/config/db.conf` and `app/README.md` (Terraform creates the folders). Add an `output` with all three paths.

### Lab 3 ⭐⭐ — Read the plan
Change one file's content and another's `file_permission`, then explain every line of `terraform plan`. Use
`terraform show` after apply to see what's in state, and `terraform output` to print outputs.

### Lab 4 ⭐⭐ — Git hygiene
Create the `.gitignore` above in your terraform folder, `git status` to prove state files aren't tracked, and
commit `.terraform.lock.hcl`. Explain to yourself why each line is there.

---

## ✅ Checkpoint
- [ ] I can explain providers, resources, state and plan
- [ ] I run `init → fmt → validate → plan → apply → destroy` and always read the plan
- [ ] I know what `+`, `~`, `-` and `-/+` mean
- [ ] I commit the lock file and never commit state

👉 Next: [Module 02 — Resources & Dependencies](../02-resources-and-dependencies/README.md)
