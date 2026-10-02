variable "name" {
  description = "Application name (lowercase letters, digits, dashes)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.name))
    error_message = "name must be lowercase letters, digits and dashes (2-31 characters)."
  }
}

variable "environment" {
  description = "dev, staging or prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "port" {
  description = "First port the app instances listen on"
  type        = number
  default     = 8000
}

variable "replicas" {
  description = "Number of app instances behind nginx"
  type        = number
  default     = 1
  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "replicas must be between 1 and 10."
  }
}

variable "out_dir" {
  description = "Where to write the generated files"
  type        = string
}
