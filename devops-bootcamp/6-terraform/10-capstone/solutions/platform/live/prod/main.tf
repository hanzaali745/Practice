# prod root module — its own state, applied only after review
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

  environment   = "prod"
  app_version   = var.app_version
  app_message   = "Hello from PROD (Terraform)"
  host          = "demo.localtest.me"
  replicas      = { min = 3, max = 10 }
  quota         = { cpu = "4", memory = "4Gi" }
  redis_storage = "2Gi"
}

output "url" {
  value = module.platform.url
}
