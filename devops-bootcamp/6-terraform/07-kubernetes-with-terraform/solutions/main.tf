# Labs 1-2 — demo-app on the kind cluster, managed by Terraform
resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = var.namespace
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}

resource "kubernetes_config_map_v1" "demo" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  data = {
    APP_MESSAGE = var.app_message
    APP_VERSION = var.app_version
  }
}

resource "kubernetes_deployment_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
    labels    = { app = "demo" }
  }

  spec {
    replicas = var.replicas

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
        labels = { app = "demo" }
        annotations = {
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.demo.data))
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
              name = kubernetes_config_map_v1.demo.metadata[0].name
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
}

resource "kubernetes_service_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  spec {
    selector = { app = "demo" }
    port {
      port        = 80
      target_port = 8000
    }
  }
}

resource "kubernetes_ingress_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
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
              name = kubernetes_service_v1.demo.metadata[0].name
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

# Lab 3: uncomment after `kubectl create namespace legacy`
# import {
#   to = kubernetes_namespace_v1.legacy
#   id = "legacy"
# }
#
# resource "kubernetes_namespace_v1" "legacy" {
#   metadata {
#     name = "legacy"
#   }
# }
