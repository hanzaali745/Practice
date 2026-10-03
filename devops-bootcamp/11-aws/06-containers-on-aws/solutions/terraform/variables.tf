variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "image" {
  type        = string
  description = "Full image reference, ideally by digest: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/demo-app@sha256:..."
}

variable "app_version" {
  type    = string
  default = "1.0.0"
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "autoscaling" {
  type        = bool
  default     = true
  description = "CPU target-tracking between 2 and 6 tasks"
}
