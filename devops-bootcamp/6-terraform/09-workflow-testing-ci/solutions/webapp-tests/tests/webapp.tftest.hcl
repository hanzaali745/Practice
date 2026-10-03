# Lab 2 — tests for the webapp module (copied from Module 06). Run: terraform init && terraform test
variables {
  name        = "shop"
  environment = "dev"
  out_dir     = "./test-out"
}

run "one_replica_by_default" {
  command = plan
  assert {
    condition     = output.ports == [8000]
    error_message = "default should be one instance on port 8000"
  }
}

run "prod_ports_are_consecutive" {
  command = plan
  variables {
    environment = "prod"
    port        = 9000
    replicas    = 3
  }
  assert {
    condition     = output.ports == [9000, 9001, 9002]
    error_message = "expected ports 9000-9002"
  }
  assert {
    condition     = strcontains(local_file.nginx_site.content, "server 127.0.0.1:9002;")
    error_message = "nginx upstream must list every instance"
  }
}

run "rejects_bad_names" {
  command = plan
  variables {
    name = "Bad_Name"
  }
  expect_failures = [var.name]
}

run "rejects_too_many_replicas" {
  command = plan
  variables {
    replicas = 11
  }
  expect_failures = [var.replicas]
}

run "files_are_created" {
  command = apply
  assert {
    condition     = fileexists("${output.app_dir}/app.conf") && fileexists("${output.app_dir}/site.conf")
    error_message = "app.conf and site.conf must be written"
  }
  assert {
    condition     = output.app_dir == "./test-out/shop-dev"
    error_message = "app_dir should be <out_dir>/<name>-<environment>"
  }
}
