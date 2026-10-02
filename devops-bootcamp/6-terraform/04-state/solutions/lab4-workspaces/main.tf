# Lab 4 — one config, one state per workspace
locals {
  env = terraform.workspace
}

resource "local_file" "env" {
  filename = "${path.module}/out/${local.env}.txt"
  content  = "this is the ${local.env} environment\n"
}
