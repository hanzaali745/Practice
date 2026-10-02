locals {
  namespace = "platform-${var.environment}"
  labels = {
    "app.kubernetes.io/part-of"    = "demo-platform"
    "app.kubernetes.io/managed-by" = "terraform"
    environment                    = var.environment
  }
}

# ---------------- namespace + guard rails ----------------
resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.namespace
    labels = merge(local.labels, {
      "pod-security.kubernetes.io/enforce" = "restricted"
    })
  }
}

resource "kubernetes_resource_quota_v1" "this" {
  metadata {
    name      = "quota"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.quota.cpu
      "requests.memory" = var.quota.memory
    }
  }
}

# ---------------- config ----------------
resource "kubernetes_config_map_v1" "app" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  data = {
    APP_MESSAGE = var.app_message
    APP_VERSION = var.app_version
    REDIS_HOST  = "redis"
  }
}

# ---------------- redis ----------------
resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    cluster_ip = "None"
    selector   = { app = "redis" }
    port {
      name = "redis"
      port = 6379
    }
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    service_name = kubernetes_service_v1.redis.metadata[0].name
    replicas     = 1
    selector {
      match_labels = { app = "redis" }
    }
    template {
      metadata {
        labels = merge(local.labels, { app = "redis" })
      }
      spec {
        automount_service_account_token = false
        security_context {
          run_as_non_root = true
          run_as_user     = 999
          run_as_group    = 999
          fs_group        = 999
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        container {
          name  = "redis"
          image = "redis:7-alpine"
          args  = ["redis-server", "--appendonly", "yes"]
          port {
            container_port = 6379
          }
          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            period_seconds = 5
          }
          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { memory = "256Mi" }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = { storage = var.redis_storage }
        }
      }
    }
  }
}

# ---------------- demo-app ----------------
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    replicas = var.replicas.min
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }
    selector {
      match_labels = { app = "demo" }
    }
    template {
      metadata {
        labels = merge(local.labels, { app = "demo" })
        annotations = {
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.app.data))
        }
      }
      spec {
        automount_service_account_token = false
        security_context {
          run_as_non_root = true
          run_as_user     = 10001
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        container {
          name              = "app"
          image             = "demo-app:${var.app_version}"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8000
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app.metadata[0].name
            }
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            period_seconds = 5
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            period_seconds = 10
          }
          resources {
            requests = { cpu = "100m", memory = "64Mi" }
            limits   = { memory = "128Mi" }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].replicas] # the HPA owns the replica count
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    selector = { app = "demo" }
    port {
      port        = 80
      target_port = 8000
    }
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = var.host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    min_replicas = var.replicas.min
    max_replicas = var.replicas.max
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.app.metadata[0].name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget_v1" "app" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    min_available = var.replicas.min > 1 ? var.replicas.min - 1 : 1
    selector {
      match_labels = { app = "demo" }
    }
  }
}

# ---------------- network policies ----------------
resource "kubernetes_network_policy_v1" "default_deny" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy_v1" "redis_from_app" {
  metadata {
    name      = "redis-from-demo-only"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = { app = "redis" }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = { app = "demo" }
        }
      }
      ports {
        port     = "6379"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "app_from_ingress" {
  metadata {
    name      = "demo-from-ingress-controller"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = { app = "demo" }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = "traefik" }
        }
      }
      ports {
        port     = "8000"
        protocol = "TCP"
      }
    }
  }
}
