# ☸️ Phase 5: Kubernetes

> **Before you start:** finish Phase 4 (Docker). You'll deploy the **same demo-app** image you built there.
> You need Docker, `kubectl`, `kind` and `helm` from [Part 2 of the Ubuntu setup](../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md),
> and about 8 GB of RAM for the 3-node lab cluster.

## Your lab cluster

Every module uses the same local cluster, created in Module 01 with
[`kind-config.yaml`](01-concepts-and-cluster/solutions/kind-config.yaml): 1 control-plane + 2 workers, with ports
80/443 mapped to your laptop for ingress. If anything gets messy: `kind delete cluster --name lab` and recreate
it — that's the beauty of a local cluster.

Load your images into it with: `kind load docker-image demo-app:1.0.0 --name lab`

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Concepts & Your Local Cluster](01-concepts-and-cluster/README.md) | 🟢 | explain the architecture, create a kind cluster, use kubectl |
| 02 | [Pods & kubectl](02-pods-and-kubectl/README.md) | 🟢 | write pod YAML, debug with describe/logs/exec, labels |
| 03 | [Deployments & Rollouts](03-deployments-and-rollouts/README.md) | 🟡 | scale, zero-downtime updates, rollbacks, Jobs/CronJobs |
| 04 | [Services & Ingress](04-services-and-ingress/README.md) | 🟡 | Services, DNS, Ingress with Traefik, Gateway API |
| 05 | [ConfigMaps & Secrets](05-configmaps-and-secrets/README.md) | 🟡 | config as env/files, secrets safely |
| 06 | [Storage & StatefulSets](06-storage-and-statefulsets/README.md) | 🔴 | PVCs, StatefulSets, backups |
| 07 | [Probes, Resources & Autoscaling](07-probes-resources-autoscaling/README.md) | 🔴 | probes, requests/limits, HPA, PDBs |
| 08 | [Helm & Kustomize](08-helm-and-kustomize/README.md) | 🔴 | overlays, charts, releases, atomic upgrades |
| 09 | [Troubleshooting & Security](09-troubleshooting-and-security/README.md) | 🔴 | debugging method, RBAC, Pod Security, NetworkPolicies |
| 10 | [Kubernetes Capstone](10-capstone/README.md) | 🏆 | a production-style platform with dev/prod and safe deploys |

## kubectl cheat sheet

```bash
kubectl config current-context                     # ALWAYS know where you are
kubectl get pods,deploy,svc,ing -n NS -o wide      # what's there
kubectl describe pod POD                           # events at the bottom!
kubectl logs POD [-c CONTAINER] [-f] [--previous]  # logs (previous = before the crash)
kubectl exec -it POD -- sh                         # shell inside
kubectl port-forward svc/SVC 8080:80               # test from your laptop
kubectl apply -f FILE.yaml | -k OVERLAY/           # declarative create/update
kubectl rollout status|history|undo|restart deploy/NAME
kubectl scale deploy/NAME --replicas=3
kubectl get events -A --sort-by=.lastTimestamp
kubectl explain deployment.spec.strategy           # built-in docs
kubectl auth can-i VERB RESOURCE --as=USER
```

## 🏅 Kubernetes expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain the control plane, nodes, kubelet, and the desired-state control loop
- [ ] Write Deployment, Service, Ingress, ConfigMap, Secret, StatefulSet, CronJob YAML from memory
- [ ] Do zero-downtime rollouts and rollbacks, and explain `maxSurge`/`maxUnavailable` + readiness
- [ ] Debug Pending, ImagePullBackOff, CrashLoopBackOff, OOMKilled and "Service has no endpoints" quickly
- [ ] Set probes and requests/limits correctly, and autoscale with an HPA
- [ ] Persist data with PVCs/StatefulSets and back it up
- [ ] Manage environments with Kustomize overlays and Helm charts; use `--atomic` upgrades
- [ ] Apply least-privilege RBAC, the `restricted` Pod Security Standard and NetworkPolicies
- [ ] Always check the current context before destructive commands
- [ ] Validate manifests in CI and deploy with automatic verification + rollback

👉 Start: [Module 01 — Concepts & Your Local Cluster](01-concepts-and-cluster/README.md)
