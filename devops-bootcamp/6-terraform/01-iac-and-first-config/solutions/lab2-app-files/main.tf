# Lab 2 — several resources and an output
terraform {
  required_version = ">= 1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "app_conf" {
  filename        = "${path.module}/app/config/app.conf"
  file_permission = "0644"
  content         = <<-EOT
    environment = dev
    port        = 8000
    log_level   = info
  EOT
}

resource "local_file" "db_conf" {
  filename        = "${path.module}/app/config/db.conf"
  file_permission = "0600" # only the owner may read database settings
  content         = <<-EOT
    host = db.internal
    port = 5432
  EOT
}

resource "local_file" "readme" {
  filename = "${path.module}/app/README.md"
  content  = "# Demo app\n\nFiles managed by Terraform — do not edit by hand.\n"
}

output "files" {
  value = [
    local_file.app_conf.filename,
    local_file.db_conf.filename,
    local_file.readme.filename,
  ]
}
