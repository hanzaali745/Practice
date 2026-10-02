output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "url" {
  value = "http://${var.host}/"
}

output "image" {
  value = "demo-app:${var.app_version}"
}
