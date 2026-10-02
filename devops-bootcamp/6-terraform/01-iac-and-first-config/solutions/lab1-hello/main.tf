# Lab 1 — your first Terraform configuration
terraform {
  required_version = ">= 1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "Hello from Terraform!\n"
}

output "hello_file" {
  value = local_file.hello.filename
}
