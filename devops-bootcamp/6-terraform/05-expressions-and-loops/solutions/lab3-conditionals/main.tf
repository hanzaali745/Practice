# Lab 3 — conditional resources and computed subnets
variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

locals {
  env_number = { dev = 1, staging = 2, prod = 3 }[var.environment]
  vpc_cidr   = "10.${local.env_number}.0.0/16"
  subnets    = [for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i)]
}

resource "local_file" "monitoring" {
  count    = var.environment == "prod" ? 1 : 0
  filename = "${path.module}/out/monitoring.conf"
  content  = "alerts = on\npager = on-call\n"
}

output "vpc_cidr" {
  value = local.vpc_cidr
}

output "subnets" {
  value = local.subnets
}

output "monitoring_enabled" {
  value = length(local_file.monitoring) > 0
}
