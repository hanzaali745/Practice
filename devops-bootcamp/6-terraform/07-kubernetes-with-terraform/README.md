# Terraform Module 07 — Terraform + Kubernetes 🔴

## 🎯 Objectives
- Configure the **Kubernetes provider** to talk to your kind cluster
- Manage namespaces, ConfigMaps, Deployments, Services and Ingresses with Terraform
- Install Helm charts with the **Helm provider**
- Understand where Terraform fits next to `kubectl`, Helm and GitOps
- Import existing Kubernetes objects

## 🧠 Why DevOps engineers care
In real companies Terraform usually builds the **cluster itself** (EKS/GKE/AKS), plus the "platform" pieces
everyone needs: namespaces, RBAC, quotas, ingress controllers, cert-manager, monitoring. Knowing how Terraform
talks to Kubernetes connects Phases 5 and 6 — and it's free to practise on your kind cluster.

> **Before you start:** create the `lab` kind cluster (Kubernetes Module 01), install Traefik (Kubernetes
> Module 04), and load `demo-app:1.0.0` into it: `kind load docker-image demo-app:1.0.0 --name lab`.

---

## 📖 Lesson 7.1 — The Kubernetes provider

```hcl
terraform {
  required_version = ">= 1.9"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-lab"          # be explicit — never "whatever context is current"
}
```
In the cloud, the provider is usually configured from the cluster resource itself
(`host = aws_eks_cluster.main.endpoint`, plus a token), so one Terraform run can create a cluster **and** set it up.

## 📖 Lesson 7.2 — Kubernetes objects as Terraform resources

Every manifest from Phase 5 has a Terraform equivalent — same fields, HCL syntax. Use the `_v1` resource names:

```hcl
resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = "tf-demo"
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}

resource "kubernetes_config_map_v1" "demo" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name   # reference → dependency
  }
  data = {
    APP_MESSAGE = "Hello from Terraform"
  }
}

resource "kubernetes_deployment_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = { app = "demo" }
    }
    template {
      metadata {
        labels = { app = "demo" }
        annotations = {
          # roll the pods when the config changes
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.demo.data))
        }
      }
      spec {
        container {
          name  = "app"
          image = "demo-app:${var.app_version}"
          port { container_port = 8000 }
          env_from {
            config_map_ref { name = kubernetes_config_map_v1.demo.metadata[0].name }
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
          }
        }
      }
    }
  }
}
```
Notice: YAML `camelCase` becomes `snake_case`, lists of objects become repeated blocks (`container { }`), and
`metadata` is accessed as `metadata[0].name`.

```bash
terraform apply -var app_version=1.0.0
kubectl -n tf-demo get all                 # the same objects, made by Terraform
terraform apply -var app_version=2.0.0     # rolling update, through Terraform
```

## 📖 Lesson 7.3 — Helm charts from Terraform

```hcl
provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-lab"
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "x.y.z"             # always pin: find the current one with `helm search repo traefik`
  namespace        = "traefik"
  create_namespace = true
  values = [yamlencode({
    ingressClass = { isDefaultClass = true }
  })]
}
```
(The Helm provider's block syntax changed between major versions — check its docs for the version you pin.)

## 📖 Lesson 7.4 — Who should manage what?

| Layer | Typical tool |
|-------|--------------|
| Cloud network, cluster, node groups, IAM | **Terraform** |
| Cluster add-ons (ingress, cert-manager, monitoring), namespaces, RBAC, quotas | **Terraform** (Helm provider) or GitOps |
| Application Deployments that change many times a day | **GitOps** (Argo CD/Flux) or Helm/kubectl in CI |

Why not apps in Terraform? Frequent deploys = frequent `terraform apply` on shared state, slow plans, and
Kubernetes controllers (like HPA) changing fields Terraform then tries to "fix". Use `lifecycle { ignore_changes =
[spec[0].replicas] }` if an HPA manages replicas.

## 📖 Lesson 7.5 — Importing existing objects

Created a namespace by hand with `kubectl`? Adopt it:
```hcl
import {
  to = kubernetes_namespace_v1.legacy
  id = "legacy"               # Kubernetes import IDs: "<name>" or "<namespace>/<name>"
}
```

---

## ⚠️ Common mistakes
- Relying on the "current" kubectl context → applying to the wrong cluster. Always set `config_context`
- Managing the same object with Terraform **and** `kubectl apply`/Helm → they fight
- Forgetting `ignore_changes` for fields changed by controllers (HPA replicas, injected annotations)
- Not pinning Helm chart versions

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). `terraform init && terraform validate` works without a cluster; `apply` needs
your kind `lab` cluster.

### Lab 1 ⭐⭐ — demo-app via Terraform
Apply `solutions/` to create namespace `tf-demo` (restricted), the ConfigMap, the Deployment (probes, resources,
non-root), a Service and an Ingress for `tf-demo.localtest.me`. `curl` it. Change `app_message`, apply, and watch
the pods roll because of the checksum annotation.

### Lab 2 ⭐⭐ — Scale and upgrade
Change `replicas` and `app_version` (load `demo-app:2.0.0` into kind first). Read the plan carefully: which
resources change in place? Then `kubectl scale` the Deployment by hand and run `terraform plan` — Terraform
wants to undo your change (drift!).

### Lab 3 ⭐⭐ — Import
Create namespace `legacy` with `kubectl create namespace legacy` and adopt it into Terraform with an `import`
block. The plan must show only the import.

### Lab 4 ⭐⭐⭐ — Platform namespaces
Use `for_each` over a map of teams to create one namespace per team with a `ResourceQuota`
(`kubernetes_resource_quota_v1`), a `LimitRange` and a read-only `RoleBinding` to the built-in `view` ClusterRole for
a group. This is exactly what platform teams automate.

---

## ✅ Checkpoint
- [ ] I configure the Kubernetes provider with an explicit context
- [ ] I can translate a manifest into `kubernetes_*_v1` resources
- [ ] I know which layers belong in Terraform vs GitOps/Helm
- [ ] I can import existing objects and handle controller-managed fields

👉 Next: [Module 08 — Terraform on AWS (optional)](../08-aws-with-terraform/README.md)
