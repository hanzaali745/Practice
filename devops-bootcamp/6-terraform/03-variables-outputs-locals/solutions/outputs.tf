output "config_file" {
  description = "Path of the generated app config"
  value       = local_file.app_conf.filename
}

output "summary" {
  description = "Facts for other tools (CI, Ansible)"
  value = {
    environment = var.environment
    replicas    = local.replicas
    port        = var.app_port
    name        = local.name_prefix
  }
}
