# Tests for the demo-platform module with a MOCKED Kubernetes provider — no cluster needed.
#   terraform init && terraform test
mock_provider "kubernetes" {}

variables {
  environment = "dev"
  app_version = "1.0.0"
  host        = "demo-dev.localtest.me"
}

run "namespace_is_restricted" {
  command = apply
  assert {
    condition     = output.namespace == "platform-dev"
    error_message = "namespace should be platform-<environment>"
  }
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["pod-security.kubernetes.io/enforce"] == "restricted"
    error_message = "namespace must enforce the restricted Pod Security Standard"
  }
}

run "app_is_hardened" {
  command = apply
  assert {
    condition     = kubernetes_deployment_v1.app.spec[0].template[0].spec[0].security_context[0].run_as_non_root
    error_message = "app must run as non-root"
  }
  assert {
    condition     = kubernetes_deployment_v1.app.spec[0].template[0].spec[0].container[0].security_context[0].read_only_root_filesystem
    error_message = "app root filesystem must be read-only"
  }
  assert {
    condition     = length(kubernetes_deployment_v1.app.spec[0].template[0].spec[0].container[0].readiness_probe) == 1
    error_message = "app needs a readiness probe"
  }
  assert {
    condition     = kubernetes_deployment_v1.app.spec[0].template[0].spec[0].container[0].image == "demo-app:1.0.0"
    error_message = "image tag must follow app_version"
  }
}

run "prod_scaling_and_pdb" {
  command = apply
  variables {
    environment = "prod"
    replicas    = { min = 3, max = 10 }
    host        = "demo.localtest.me"
  }
  assert {
    condition     = kubernetes_horizontal_pod_autoscaler_v2.app.spec[0].min_replicas == 3 && kubernetes_horizontal_pod_autoscaler_v2.app.spec[0].max_replicas == 10
    error_message = "HPA must use the requested min/max"
  }
  assert {
    condition     = kubernetes_pod_disruption_budget_v1.app.spec[0].min_available == "2"
    error_message = "PDB must keep min-1 pods available"
  }
}

run "network_is_locked_down" {
  command = apply
  assert {
    condition     = length(kubernetes_network_policy_v1.default_deny.spec[0].policy_types) == 1
    error_message = "default-deny policy missing"
  }
  assert {
    condition     = kubernetes_network_policy_v1.redis_from_app.spec[0].ingress[0].ports[0].port == "6379"
    error_message = "redis must only allow port 6379"
  }
}

run "rejects_latest_tag" {
  command = plan
  variables {
    app_version = "latest"
  }
  expect_failures = [var.app_version]
}

run "rejects_bad_replicas" {
  command = plan
  variables {
    replicas = { min = 5, max = 2 }
  }
  expect_failures = [var.replicas]
}
