# Lab 4 — step 1: a plain resource in the root module (apply this first)
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "config" {
  filename = "${path.root}/out/shop-dev/app.conf"
  content  = <<-EOT
    name        = shop
    environment = dev
    ports       = 8000
  EOT
}
