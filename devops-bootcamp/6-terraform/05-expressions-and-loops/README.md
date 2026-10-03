# Terraform Module 05 — Expressions, Loops & Functions 🔴

## 🎯 Objectives
- Create many resources with `count` and `for_each` — and know why `for_each` is usually better
- Transform data with `for` expressions, conditionals and splats
- Generate nested blocks with `dynamic`
- Use the most useful built-in functions (`templatefile`, `merge`, `lookup`, `cidrsubnet`, `jsonencode`...)
- Experiment with `terraform console`

## 🧠 Why DevOps engineers care
Real configs create "one bucket per team", "three subnets per availability zone", "a DNS record per service".
Loops and expressions turn 300 lines of copy-paste into 20 lines driven by data — and choosing `for_each`
over `count` is the difference between a safe change and Terraform destroying the wrong server.

---

## 📖 Lesson 5.1 — `count`

```hcl
variable "users" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

resource "local_file" "user" {
  count    = length(var.users)
  filename = "${path.module}/users/${var.users[count.index]}.txt"
  content  = "user ${var.users[count.index]}\n"
}
# addresses: local_file.user[0], local_file.user[1], local_file.user[2]
```

`count` is great for "N identical things" and for **on/off** switches:
```hcl
resource "local_file" "monitoring" {
  count    = var.environment == "prod" ? 1 : 0     # create only in prod
  filename = "${path.module}/monitoring.conf"
  content  = "alerts = on\n"
}
```

⚠️ **The count trap:** remove `"bob"` from the middle of the list → `user[1]` becomes carol and `user[2]`
disappears → Terraform **changes/destroys the wrong things**. With servers, that's an outage.

## 📖 Lesson 5.2 — `for_each` (prefer this)

Resources are keyed by a **stable name**, not a position:
```hcl
variable "users" {
  type = map(object({
    team  = string
    admin = bool
  }))
  default = {
    alice = { team = "platform", admin = true }
    bob   = { team = "data", admin = false }
    carol = { team = "platform", admin = false }
  }
}

resource "local_file" "user" {
  for_each = var.users                       # a map or a set of strings
  filename = "${path.module}/users/${each.key}.txt"
  content  = "team=${each.value.team} admin=${each.value.admin}\n"
}
# addresses: local_file.user["alice"], local_file.user["bob"], local_file.user["carol"]
```
Remove bob → **only** `local_file.user["bob"]` is destroyed. ✅

`for_each` over a list? Convert it: `for_each = toset(var.names)`.

## 📖 Lesson 5.3 — `for` expressions

Like Python comprehensions (Python Module 05!):
```hcl
locals {
  servers = {
    web-01 = { ip = "10.0.1.10", role = "web" }
    web-02 = { ip = "10.0.1.11", role = "web" }
    db-01  = { ip = "10.0.2.10", role = "db" }
  }

  names       = [for name, s in local.servers : name]                          # list
  upper_names = [for name in local.names : upper(name)]
  web_ips     = [for name, s in local.servers : s.ip if s.role == "web"]       # filter
  ip_by_name  = { for name, s in local.servers : name => s.ip }               # map
  by_role     = { for name, s in local.servers : s.role => name... }          # group: role => [names]
}
```

**Splat** — get one attribute from every instance:
```hcl
output "user_files" {
  value = values(local_file.user)[*].filename     # for_each resources are maps → values()
}
```

## 📖 Lesson 5.4 — Conditionals and null

```hcl
locals {
  instance_size = var.environment == "prod" ? "large" : "small"
  log_level     = coalesce(var.log_level, "info")          # first non-null/non-empty value
}

resource "local_file" "cfg" {
  filename        = "${path.module}/cfg.txt"
  content         = "size=${local.instance_size}\n"
  file_permission = var.restrict_permissions ? "0600" : null   # null = "use the provider's default"
}
```

## 📖 Lesson 5.5 — Templates: `templatefile`

Keep big text out of `.tf` files. `templates/inventory.tftpl`:
```
[web]
%{ for name, s in servers ~}
%{ if s.role == "web" ~}
${name} ansible_host=${s.ip}
%{ endif ~}
%{ endfor ~}
```
```hcl
resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content  = templatefile("${path.module}/templates/inventory.tftpl", { servers = local.servers })
}
```
This is exactly how Terraform hands servers it created to **Ansible** (Phase 7).

## 📖 Lesson 5.6 — `dynamic` blocks

Some resources have repeated **nested blocks** (security group rules, env vars, volumes). Generate them:
```hcl
variable "ingress_rules" {
  default = [
    { port = 22,  cidr = "10.0.0.0/8",  description = "SSH from VPN" },
    { port = 443, cidr = "0.0.0.0/0",   description = "HTTPS" },
  ]
}

resource "aws_security_group" "web" {
  name = "web"
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }
}
```
Use `dynamic` only when the list really varies — readability first.

## 📖 Lesson 5.7 — Functions you'll use all the time

| Function | Example | Result |
|----------|---------|--------|
| `merge` | `merge({a=1}, {b=2})` | `{a=1, b=2}` |
| `lookup` | `lookup(var.sizes, "prod", "small")` | value or default |
| `contains` | `contains(["dev","prod"], "dev")` | `true` |
| `length`, `keys`, `values` | `keys(local.servers)` | `["db-01","web-01","web-02"]` |
| `join`, `split` | `join(",", ["a","b"])` | `"a,b"` |
| `format` | `format("web-%02d", 7)` | `"web-07"` |
| `flatten` | `flatten([[1],[2,3]])` | `[1,2,3]` |
| `cidrsubnet` | `cidrsubnet("10.0.0.0/16", 8, 2)` | `"10.0.2.0/24"` |
| `jsonencode`, `yamlencode` | `jsonencode({a=1})` | `"{\"a\":1}"` |
| `file`, `templatefile` | read a file / render a template | |
| `try`, `can` | `try(var.x.y, "default")` | safe access |

```bash
terraform console
> cidrsubnet("10.0.0.0/16", 8, 1)
> [for i in range(3) : format("web-%02d", i + 1)]
> merge({team = "a"}, {env = "dev"})
```

---

## ⚠️ Common mistakes
- `count` for things identified by name → destroying the wrong resource when the list changes
- Using values only known after apply in `for_each` keys → "Invalid for_each argument" (keys must be known at plan time)
- Giant nested `for` expressions nobody can read — split into named locals
- `dynamic` blocks for static content
- Forgetting `values()` when splatting a `for_each` resource

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — run `./check.sh` to see every lab's behaviour.

### Lab 1 ⭐⭐ — The count trap
Create user files from a **list** with `count`. Remove the middle user and read the plan (wrong things change!).
Rewrite with `for_each` over a **map** and repeat: only that user's file is destroyed.

### Lab 2 ⭐⭐ — Inventory generator
From a `servers` map, use `for` expressions and `templatefile` to generate an Ansible `inventory.ini` grouped by
role and an nginx `upstream.conf` listing only web servers. Output a map of name → IP.

### Lab 3 ⭐⭐ — Conditional resources and subnets
Variable `environment`: create `monitoring.conf` only in prod (`count = ... ? 1 : 0`). Compute three /24 subnets
from `10.<env_number>.0.0/16` with `cidrsubnet` and output them.

### Lab 4 ⭐⭐⭐ — Dynamic blocks (validate-only)
Write an `aws_security_group` whose ingress rules come from a list variable via `dynamic`. You **don't** need an
AWS account: `terraform init` + `terraform validate` checks it against the AWS provider's schema without
creating anything.

---

## ✅ Checkpoint
- [ ] I prefer `for_each` with stable keys, and use `count` for on/off
- [ ] I can write `for` expressions that filter, map and group
- [ ] I can render config files with `templatefile`
- [ ] I know the common functions and test ideas in `terraform console`

👉 Next: [Module 06 — Modules](../06-modules/README.md)
