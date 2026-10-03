# Terraform Module 02 — Resources & Dependencies 🟢

## 🎯 Objectives
- Use attributes of one resource in another (references)
- Understand **implicit** and **explicit** (`depends_on`) dependencies and the resource graph
- Read data with **data sources**
- Control replacement and deletion with `lifecycle`
- Force a replacement with `-replace`; know why provisioners are a last resort

## 🧠 Why DevOps engineers care
Real infrastructure is a web of dependencies: the subnet needs the VPC, the server needs the subnet and the
security group, DNS needs the server's IP. Terraform builds the order for you from references — if you
understand the graph, you understand why Terraform does what it does (and how to stop it from destroying
your database).

---

## 📖 Lesson 2.1 — References connect resources

```hcl
resource "random_pet" "server" {        # generates a name like "witty-gecko"
  length = 2
}

resource "random_password" "db" {
  length  = 20
  special = true
}

resource "local_file" "inventory" {
  filename = "${path.module}/inventory.ini"
  content  = "server_name = ${random_pet.server.id}\n"     # ← reference = dependency
}

resource "local_sensitive_file" "db_creds" {               # file content hidden in plan output
  filename = "${path.module}/db.env"
  content  = "DB_PASSWORD=${random_password.db.result}\n"
}
```

Because `local_file.inventory` uses `random_pet.server.id`, Terraform **must** create the pet first.
Independent resources are created **in parallel**.

## 📖 Lesson 2.2 — The dependency graph

```bash
terraform graph -type=plan | dot -Tsvg > graph.svg     # needs: sudo apt install graphviz
```
```
random_pet.server ──► local_file.inventory
random_password.db ──► local_sensitive_file.db_creds
```
On destroy, Terraform walks the graph **backwards**.

## 📖 Lesson 2.3 — Explicit dependencies: `depends_on`

When there's a dependency Terraform can't see (no reference), declare it:
```hcl
resource "local_file" "ready_marker" {
  filename   = "${path.module}/READY"
  content    = "all config written\n"
  depends_on = [local_file.inventory, local_sensitive_file.db_creds]
}
```
Use `depends_on` sparingly — references are clearer. A typical real case: an app that needs an IAM policy
to be attached before it starts, even though it doesn't reference the policy.

## 📖 Lesson 2.4 — Data sources: read, don't manage

A **data source** looks something up without creating or owning it:
```hcl
data "local_file" "ssh_key" {
  filename = pathexpand("~/.ssh/id_ed25519.pub")
}

output "key_fingerprint_source" {
  value = substr(data.local_file.ssh_key.content, 0, 30)
}
```
In the cloud you'll use data sources constantly: "the latest Ubuntu AMI", "the existing VPC called prod",
"my AWS account ID".

## 📖 Lesson 2.5 — `terraform_data` and `null_resource`

`terraform_data` (built in, no provider needed) stores a value and can trigger replacement of other resources:
```hcl
resource "terraform_data" "app_version" {
  input = var.app_version           # changes when the version changes
}

resource "local_file" "deployed" {
  filename = "${path.module}/deployed.txt"
  content  = "deployed at ${timestamp()}\n"
  lifecycle {
    replace_triggered_by = [terraform_data.app_version]   # re-create when the version changes
  }
}
```

## 📖 Lesson 2.6 — `lifecycle`: control changes

```hcl
resource "local_file" "important" {
  filename = "${path.module}/important.txt"
  content  = "do not lose me\n"

  lifecycle {
    prevent_destroy       = true      # `terraform destroy` / replacements FAIL with an error
    create_before_destroy = true      # build the replacement before removing the old (zero downtime)
    ignore_changes        = [content] # changes made outside Terraform to these attributes are ignored
  }
}
```

| Setting | Typical use |
|---------|-------------|
| `prevent_destroy` | databases, S3 buckets with data, DNS zones |
| `create_before_destroy` | servers/load balancer targets that must stay available |
| `ignore_changes` | attributes another system changes (autoscaling group size, tags added by a tool) |
| `replace_triggered_by` | re-create when something else changes |

## 📖 Lesson 2.7 — Forcing a replacement

```bash
terraform apply -replace=random_pet.server     # re-create just this resource (e.g. a broken server)
```
(Older material uses `terraform taint` — it's deprecated in favour of `-replace`.)

## 📖 Lesson 2.8 — Provisioners: avoid them

`local-exec` / `remote-exec` provisioners run scripts during create/destroy. They're not tracked in state,
can't be planned, and fail in confusing ways. Prefer: cloud-init/user-data, configuration management
(**Ansible** — Phase 7), or images built with Packer. Use provisioners only when nothing else works.

---

## ⚠️ Common mistakes
- Hard-coding values that another resource produces (copy-pasting an ID) instead of referencing it
- `depends_on` everywhere "to be safe" → slower plans and confusing graphs
- Forgetting `prevent_destroy` on stateful resources
- `ignore_changes = all` hiding real drift
- Secrets in normal `local_file` → visible in plan output (use `local_sensitive_file` / `sensitive = true`)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Generated values
Use `random_pet` and `random_password` to generate a server name and DB password, write an `inventory.ini`
and a sensitive `db.env`. Note how the password is hidden in `plan` output but visible in the state file — why
state must be protected.

### Lab 2 ⭐⭐ — Graph and order
Add a `READY` marker that depends on both files. Run `terraform graph`, then `apply` with
`-parallelism=1` and watch the order. Destroy and watch it reverse.

### Lab 3 ⭐⭐ — Protect and replace
Add `prevent_destroy` to the inventory file and try `terraform destroy` — read the error. Use
`terraform apply -replace=random_pet.server` and follow how the change flows through to the inventory file.

### Lab 4 ⭐⭐⭐ — Version-triggered redeploy
Add `variable "app_version"` + `terraform_data` + `replace_triggered_by` so a `deployed.txt` file is recreated
only when the version changes. Prove it: apply twice with the same version (no changes), then with a new one.

---

## ✅ Checkpoint
- [ ] I connect resources with references and can read the graph
- [ ] I know when `depends_on` is actually needed
- [ ] I can use data sources and `terraform_data`
- [ ] I use `lifecycle` to protect important resources

👉 Next: [Module 03 — Variables, Outputs & Locals](../03-variables-outputs-locals/README.md)
