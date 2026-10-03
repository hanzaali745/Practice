variable "environment" {
  description = "dev, staging or prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "app_version" {
  description = "demo-app image tag"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.app_version))
    error_message = "app_version must be a semantic version like 1.2.3 (never 'latest')."
  }
}

variable "app_message" {
  type    = string
  default = "Hello from the Terraform platform"
}

variable "replicas" {
  description = "min/max replicas for the autoscaler"
  type = object({
    min = number
    max = number
  })
  default = { min = 2, max = 6 }
  validation {
    condition     = var.replicas.min >= 1 && var.replicas.max >= var.replicas.min
    error_message = "replicas.min must be >= 1 and replicas.max >= replicas.min."
  }
}

variable "host" {
  description = "Ingress hostname"
  type        = string
}

variable "quota" {
  description = "Namespace resource quota"
  type = object({
    cpu    = string
    memory = string
  })
  default = { cpu = "2", memory = "2Gi" }
}

variable "redis_storage" {
  type    = string
  default = "1Gi"
}
