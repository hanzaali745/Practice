# Labs 1-4 — generated values, dependencies, lifecycle and version-triggered replacement
terraform {
  required_version = ">= 1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "app_version" {
  description = "Changing this re-creates deployed.txt (Lab 4)"
  type        = string
  default     = "1.0.0"
}

# ---- Lab 1: generated values ----
resource "random_pet" "server" {
  length = 2
}

resource "random_password" "db" {
  length  = 20
  special = true
}

resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content  = <<-EOT
    [web]
    ${random_pet.server.id} ansible_host=10.0.1.10
  EOT

  # Lab 3: uncomment, then try `terraform destroy`
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "local_sensitive_file" "db_creds" {
  filename        = "${path.module}/out/db.env"
  file_permission = "0600"
  content         = "DB_PASSWORD=${random_password.db.result}\n"
}

# ---- Lab 2: explicit dependency ----
resource "local_file" "ready_marker" {
  filename   = "${path.module}/out/READY"
  content    = "all config written\n"
  depends_on = [local_file.inventory, local_sensitive_file.db_creds]
}

# ---- Lab 4: re-create only when the version changes ----
resource "terraform_data" "app_version" {
  input = var.app_version
}

resource "local_file" "deployed" {
  filename = "${path.module}/out/deployed.txt"
  content  = "version ${var.app_version} deployed\n"
  lifecycle {
    replace_triggered_by = [terraform_data.app_version]
  }
}

output "server_name" {
  value = random_pet.server.id
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true # hidden in CLI output; read with: terraform output -raw db_password
}
