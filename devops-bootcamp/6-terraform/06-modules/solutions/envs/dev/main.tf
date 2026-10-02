# Lab 2 + 3 — dev: three small apps from the same module
module "web" {
  source   = "../../modules/webapp"
  for_each = { shop = 8000, blog = 8100, api = 8200 }

  name        = each.key
  environment = "dev"
  port        = each.value
  replicas    = 1
  out_dir     = "${path.root}/out"
}

output "ports" {
  value = { for app, m in module.web : app => m.ports }
}
