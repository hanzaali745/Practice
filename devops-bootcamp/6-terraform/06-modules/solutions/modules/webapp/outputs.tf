output "config_file" {
  description = "Path of app.conf"
  value       = local_file.config.filename
}

output "app_dir" {
  description = "Folder with all generated files"
  value       = local.app_dir
}

output "ports" {
  description = "Ports of the app instances"
  value       = local.ports
}
