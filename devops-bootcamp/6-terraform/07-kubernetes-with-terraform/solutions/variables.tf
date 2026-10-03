variable "kubeconfig" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "kubectl context to use — explicit, so you never apply to the wrong cluster"
  type        = string
  default     = "kind-lab"
}

variable "namespace" {
  type    = string
  default = "tf-demo"
}

variable "app_version" {
  description = "demo-app image tag (must be loaded into kind)"
  type        = string
  default     = "1.0.0"
}

variable "app_message" {
  type    = string
  default = "Hello from Terraform"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "host" {
  description = "Ingress hostname"
  type        = string
  default     = "tf-demo.localtest.me"
}
