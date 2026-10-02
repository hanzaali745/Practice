# Lab 4 — one namespace per team, with quota, default limits and read-only access for the team's group
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

variable "teams" {
  type = map(object({
    cpu    = string
    memory = string
    group  = string
  }))
  default = {
    payments = { cpu = "4", memory = "8Gi", group = "team-payments" }
    search   = { cpu = "2", memory = "4Gi", group = "team-search" }
  }
}

resource "kubernetes_namespace_v1" "team" {
  for_each = var.teams
  metadata {
    name = "team-${each.key}"
    labels = {
      team                                 = each.key
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

resource "kubernetes_resource_quota_v1" "team" {
  for_each = var.teams
  metadata {
    name      = "quota"
    namespace = kubernetes_namespace_v1.team[each.key].metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = each.value.cpu
      "requests.memory" = each.value.memory
      pods              = "50"
    }
  }
}

resource "kubernetes_limit_range_v1" "team" {
  for_each = var.teams
  metadata {
    name      = "defaults"
    namespace = kubernetes_namespace_v1.team[each.key].metadata[0].name
  }
  spec {
    limit {
      type            = "Container"
      default         = { memory = "256Mi" }
      default_request = { cpu = "100m", memory = "64Mi" }
    }
  }
}

resource "kubernetes_role_binding_v1" "team_view" {
  for_each = var.teams
  metadata {
    name      = "team-view"
    namespace = kubernetes_namespace_v1.team[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = each.value.group
    api_group = "rbac.authorization.k8s.io"
  }
}

output "namespaces" {
  value = [for ns in kubernetes_namespace_v1.team : ns.metadata[0].name]
}
