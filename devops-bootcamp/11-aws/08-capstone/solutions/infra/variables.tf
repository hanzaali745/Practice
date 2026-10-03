variable "name" {
  type    = string
  default = "demo-app"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "nat_gateway" {
  type        = bool
  default     = true
  description = "true: tasks in private subnets behind a NAT gateway (~$35/month). false: lab mode, tasks in public subnets with public IPs (still only reachable through the ALB)"
}

variable "image_tag" {
  type        = string
  description = "The tag of the FIRST image pushed to ECR (e.g. sha-abc1234). Later releases come from the pipeline"
}

variable "github_repo" {
  type        = string
  description = "owner/name of the repository whose 'production' environment may deploy"
  validation {
    condition     = can(regex("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "github_repo must look like owner/name."
  }
}

variable "github_oidc_provider_arn" {
  type        = string
  default     = ""
  description = "An account has ONE GitHub OIDC provider. Empty: create it here. Already have one: pass its ARN"
}

variable "alert_email" {
  type        = string
  default     = ""
  description = "Where alarms are sent (confirm the subscription email). Empty: no email subscription"
}

variable "autoscaling" {
  type        = bool
  default     = true
  description = "CPU target tracking between 2 and 6 tasks (local AWS: false — moto never finishes creating it)"
}

variable "alarms" {
  type        = bool
  default     = true
  description = "CloudWatch alarms (local AWS: false — moto can't decode the provider's CBOR-encoded alarm requests)"
}
