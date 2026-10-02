# dev root module — its own state, deploys automatically
terraform {
  required_version = ">= 1.9"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-lab"
}

variable "app_version" {
  type    = string
  default = "1.0.0"
}

module "platform" {
  source = "../../modules/demo-platform"

  environment = "dev"
  app_version = var.app_version
  app_message = "Hello from DEV (Terraform)"
  host        = "demo-dev.localtest.me"
  replicas    = { min = 1, max = 3 }
  quota       = { cpu = "1", memory = "1Gi" }
}

output "url" {
  value = module.platform.url
}
