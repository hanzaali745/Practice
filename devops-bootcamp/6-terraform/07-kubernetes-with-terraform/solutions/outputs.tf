output "url" {
  value = "http://${var.host}/"
}

output "namespace" {
  value = kubernetes_namespace_v1.demo.metadata[0].name
}
