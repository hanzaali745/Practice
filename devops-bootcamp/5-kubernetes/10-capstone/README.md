# Kubernetes Module 10 — Kubernetes Capstone 🏆

> **CEO note:** This is the project that shows you can run real services on Kubernetes. Keep it in Git,
> validate it in CI, and be ready to explain every line in an interview.

**Definition of Done:**
- [ ] Everything is YAML in Git — no hand-made resources (`kubectl edit` only for experiments)
- [ ] dev and prod from **one** base (Kustomize overlays or a Helm chart with values files)
- [ ] Every container: requests/limits, readiness + liveness probes, non-root, read-only root FS, no capabilities
- [ ] Namespaces enforce the `restricted` Pod Security Standard
- [ ] Ingress, HPA, PDB, NetworkPolicies (default deny + explicit allows)
- [ ] Stateful parts in a StatefulSet with persistent storage and a backup plan
- [ ] A deploy script/pipeline that verifies the rollout and rolls back on failure
- [ ] Manifests validated in CI (kubeconform)

---

## Project 1 ⭐⭐⭐ — The demo platform (full reference solution)

demo-app + Redis on your kind cluster, production-style:

```
                         ┌──────────── namespace demo-prod (restricted) ─────────────┐
 demo.localtest.me ─► Traefik ─► Service demo ─► Deployment demo (HPA 3–10, PDB ≥2)  │
                         │                              │ REDIS_HOST=redis            │
                         │                     StatefulSet redis + PVC              │
                         │   NetworkPolicies: default deny · traefik→demo · demo→redis │
                         └────────────────────────────────────────────────────────────┘
```

👉 Reference: [`solutions/platform/`](solutions/platform/)

```bash
cd solutions/platform
./validate.sh                    # render + schema-validate both overlays
./deploy.sh dev 1.0.0            # build, kind load, apply, wait, smoke test (rolls back on failure)
curl http://demo-dev.localtest.me/visits
./deploy.sh prod 1.0.0
./deploy.sh prod 1.1.0           # rolling update, zero downtime
```

Prerequisites: the `lab` cluster from Module 01, Traefik from Module 04, metrics-server from Module 07.

**Stretch goals:**
- **GitOps:** install **Argo CD** and point an `Application` at `overlays/prod` in your Git repo — deploy by
  merging a pull request instead of running a script
- Redis backup CronJob from Module 06, with backups copied off the cluster
- Convert the platform into a Helm chart (Module 08) and compare the two approaches

---

## Project 2 ⭐⭐⭐ — Observability
Install **kube-prometheus-stack** with Helm (Prometheus + Grafana + Alertmanager). Add a `/metrics` endpoint to
demo-app (request count), scrape it with a `ServiceMonitor`, build a Grafana dashboard, and create an alert that
fires when error rate > 5%.

## Project 3 ⭐⭐ — Jobs platform
Run your Python `logwatch` or `backupctl` (Python capstone) as Kubernetes **CronJobs** with ConfigMaps for config,
Secrets for credentials, a PVC for output, resource limits, and `concurrencyPolicy: Forbid`.

## Project 4 ⭐⭐⭐ — Chaos day
On your platform: delete random pods during a load test, `docker stop` a worker node, fill Redis' memory limit,
push a broken image, break a NetworkPolicy. For each, write what users saw, how you detected it, and how the
platform recovered (or what you changed so it would next time).

---

## 🎓 Kubernetes phase complete!
Tick the [Kubernetes expert checklist](../README.md#-kubernetes-expert-checklist). Then move on — next you'll build
the infrastructure that clusters run on.

👉 Next phase: [Phase 6 — Terraform](../../6-terraform/README.md)
