# Lab 2 — prod: one app, more replicas
module "web" {
  source = "../../modules/webapp"

  name        = "shop"
  environment = "prod"
  port        = 9000
  replicas    = 3
  out_dir     = "${path.root}/out"
}

output "ports" {
  value = module.web.ports
}
