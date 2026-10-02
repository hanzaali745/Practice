# Lab 2 — generate an Ansible inventory and an nginx upstream from one data structure
variable "servers" {
  type = map(object({
    ip   = string
    role = string
  }))
  default = {
    web-01 = { ip = "10.0.1.10", role = "web" }
    web-02 = { ip = "10.0.1.11", role = "web" }
    db-01  = { ip = "10.0.2.10", role = "db" }
  }
}

locals {
  roles      = distinct([for s in var.servers : s.role])
  by_role    = { for name, s in var.servers : s.role => name... } # role => [names]
  web_ips    = [for name, s in var.servers : s.ip if s.role == "web"]
  ip_by_name = { for name, s in var.servers : name => s.ip }
}

resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    servers = var.servers
    by_role = local.by_role
  })
}

resource "local_file" "upstream" {
  filename = "${path.module}/out/upstream.conf"
  content  = templatefile("${path.module}/templates/upstream.tftpl", { ips = local.web_ips })
}

output "ip_by_name" {
  value = local.ip_by_name
}

output "roles" {
  value = local.roles
}
