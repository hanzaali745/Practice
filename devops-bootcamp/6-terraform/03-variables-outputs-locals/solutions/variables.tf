variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "app_port" {
  description = "Port the app listens on"
  type        = number
  default     = 8000
  validation {
    condition     = var.app_port >= 1024 && var.app_port <= 65535
    error_message = "app_port must be between 1024 and 65535 (no privileged ports)."
  }
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be one of: debug, info, warn, error."
  }
}

variable "replicas" {
  description = "Requested number of app instances (prod always gets at least 3)"
  type        = number
  default     = 1
  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10 && floor(var.replicas) == var.replicas
    error_message = "replicas must be a whole number from 1 to 10."
  }
}

variable "tags" {
  description = "Extra tags/labels for everything"
  type        = map(string)
  default     = { team = "platform" }
}

variable "db_password" {
  description = "Database password — provide via TF_VAR_db_password, never in a file"
  type        = string
  sensitive   = true
}
