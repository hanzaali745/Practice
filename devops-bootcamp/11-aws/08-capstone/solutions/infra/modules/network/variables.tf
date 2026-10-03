variable "name" {
  type = string
}

variable "cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "At least two availability zones: the ALB needs two, and so does surviving the loss of one"
  validation {
    condition     = length(var.azs) >= 2
    error_message = "Use at least two availability zones."
  }
}

variable "nat_gateway" {
  type        = bool
  description = "One NAT gateway for the private subnets (~$35/month). Without it, nothing in the private subnets reaches the internet"
}
