variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "task_subnet_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  type        = bool
  description = "true only when tasks run in public subnets (no NAT gateway): they need a public IP to pull images"
}

variable "image" {
  type        = string
  description = "The FIRST image only. After that the pipeline deploys new task definition revisions"
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Plain environment variables for the container (never secrets: use Secrets Manager + the secrets block)"
}

variable "min_tasks" {
  type    = number
  default = 2
}

variable "max_tasks" {
  type    = number
  default = 6
}

variable "autoscaling" {
  type    = bool
  default = true
}

variable "log_retention_days" {
  type    = number
  default = 14
}
