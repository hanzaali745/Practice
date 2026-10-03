# Monitoring Module 07 — Monitoring Kubernetes 🔴

## 🎯 Objectives
- Install the **kube-prometheus-stack** (Prometheus Operator, Prometheus, Alertmanager, Grafana, node-exporter,
  kube-state-metrics) with Helm
- Know what each piece monitors: nodes, containers (cAdvisor), Kubernetes objects (kube-state-metrics)
- Scrape your app with a **ServiceMonitor** and load rules with a **PrometheusRule**
- Ship dashboards as **ConfigMaps** picked up by Grafana's sidecar
- Write the queries every Kubernetes on-call engineer needs: restarts, OOMKills, pending pods, saturation

## 🧠 Why DevOps engineers care
Almost every company running Kubernetes runs this stack (or a managed version of it). In Kubernetes nothing has a fixed
address, so monitoring has to be driven by labels and Kubernetes objects. ServiceMonitors and PrometheusRules let each
team ship monitoring next to its app — in Git, deployed by the same pipeline (Phase 8).

---

## 📖 Lesson 7.1 — The stack

```
                    ┌────────────── namespace: monitoring ─────────────────────────────────┐
 ServiceMonitor ──► │ Prometheus Operator ──configures──► Prometheus ──alerts──► Alertmanager │
 PrometheusRule ──► │                                         ▲ scrapes                    │
 ConfigMap(dash) ─► │ Grafana (sidecar loads dashboards)      │                            │
                    └─────────────────────────────────────────┼────────────────────────────┘
          node-exporter (every node) · kubelet/cAdvisor (every container) · kube-state-metrics (objects) · your apps
```
| Source | Gives you | Example metric |
|--------|-----------|----------------|
| node-exporter | machines | `node_memory_MemAvailable_bytes` |
| kubelet / cAdvisor | containers | `container_cpu_usage_seconds_total`, `container_memory_working_set_bytes` |
| kube-state-metrics | Kubernetes objects | `kube_pod_container_status_restarts_total`, `kube_deployment_status_replicas_available` |
| your ServiceMonitors | apps | `http_requests_total` |

## 📖 Lesson 7.2 — Install it

```bash
cd ~/Practice/devops-bootcamp/9-monitoring/07-kubernetes-monitoring/solutions
./install_stack.sh                    # helm upgrade --install ... --version 91.9.0 -f values.yaml --wait
kubectl -n monitoring get pods
```
[`values.yaml`](solutions/values.yaml) keeps it lab-sized and sets one important thing:
```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false   # watch ALL ServiceMonitors, not only this release's
    ruleSelectorNilUsesHelmValues: false
```
Without that, your ServiceMonitor is silently ignored unless it carries the label `release: monitoring` — the
most common "why isn't Prometheus scraping my app?" question.

The stack ships dozens of dashboards (Kubernetes / Compute Resources / Namespace, Node Exporter, …) and alerts
(`KubePodCrashLooping`, `KubeDeploymentReplicasMismatch`, `NodeFilesystemSpaceFillingUp`, …) out of the box.

## 📖 Lesson 7.3 — ServiceMonitor: scrape your app

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata: {name: demo-app, namespace: demo}
spec:
  selector:
    matchLabels: {app: demo-app}       # Services with this label...
  endpoints:
    - port: http                       # ...on the port NAMED "http"
      path: /metrics
      interval: 15s
```
The operator turns it into Prometheus config. Pods scale up and down, IPs change — Prometheus follows.
(`PodMonitor` does the same for pods without a Service.) Check **Status → Target health** for
`serviceMonitor/demo/demo-app/0`.

## 📖 Lesson 7.4 — PrometheusRule and dashboards as objects

[`prometheusrule.yaml`](solutions/prometheusrule.yaml) is the Module 06 rules wrapped in a Kubernetes object — the
app team owns it in their repo. [`make_dashboard_configmap.sh`](solutions/make_dashboard_configmap.sh) wraps the
Module 05 dashboard JSON in a ConfigMap labelled `grafana_dashboard: "1"`; Grafana's sidecar loads it in seconds.
The dashboard uses data source uid `prometheus`, which is exactly what this chart provisions — so it works unchanged.

```bash
kubectl apply -f demo-app.yaml -f servicemonitor.yaml -f prometheusrule.yaml -f dashboard-configmap.yaml
```

## 📖 Lesson 7.5 — Queries for Kubernetes on-call

```promql
sum by (namespace, pod) (rate(container_cpu_usage_seconds_total{container!=""}[5m]))           # CPU per pod (cores)
sum by (namespace, pod) (container_memory_working_set_bytes{container!=""})                     # memory per pod
increase(kube_pod_container_status_restarts_total[1h]) > 0                                       # restarting pods
kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}                            # OOMKilled containers
sum by (namespace) (kube_pod_status_phase{phase="Pending"}) > 0                                  # pods that can't schedule
kube_deployment_status_replicas_available / kube_deployment_spec_replicas < 1                    # degraded deployments
sum by (pod) (rate(container_cpu_cfs_throttled_periods_total[5m]))
  / sum by (pod) (rate(container_cpu_cfs_periods_total[5m]))                                    # CPU throttling ratio
```
Compare requests and limits with real usage — that's how you right-size pods (Phase 5, Module 07).

## 📖 Lesson 7.6 — Validate before you apply

[`validate.sh`](solutions/validate.sh) works without a cluster: kubeconform checks every manifest **including the
CRDs** against their schemas; promtool checks the rules inside the PrometheusRule; and a small script compares every
key in `values.yaml` with the pinned chart's own `values.yaml` — Helm silently ignores misspelled keys, so a typo like
`serviceMonitorSelectorNilUseHelmValues` would otherwise cost you an afternoon.

---

## ⚠️ Common mistakes
- ServiceMonitor ignored because of the release-label selector (Lesson 7.2)
- `port:` in the ServiceMonitor refers to a port **name** — unnamed Service ports can't be selected
- Huge cardinality from pod-level labels on high-traffic metrics
- Keeping Prometheus data on an `emptyDir` in production (lost on restart) — use persistent storage and set retention
- Installing without pinning the chart version — upgrades change CRDs and defaults

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Needs your kind cluster from Phase 5 (8 GB RAM recommended). `./validate.sh`
works without a cluster.

### Lab 1 ⭐⭐ — Install and explore
Run `install_stack.sh`, port-forward Grafana, and open **Kubernetes / Compute Resources / Namespace (Pods)** and
**Node Exporter / Nodes**. Find the alerts that are already firing in a fresh kind cluster and explain one.

### Lab 2 ⭐⭐ — Your app
Load `demo-app:1.0.0` into kind, apply `demo-app.yaml` and `servicemonitor.yaml`. Find the target, then query
`sum by (pod) (rate(http_requests_total[5m]))` while you send traffic through a port-forward.

### Lab 3 ⭐⭐ — Rules and dashboards as objects
Apply `prometheusrule.yaml` and the dashboard ConfigMap. Delete one demo-app pod's container process
(`kubectl exec … -- kill 1`) and watch the rules react. Then scale demo-app to **0**: why does `DemoAppDown` never fire?
(There's no `up` series left to be 0.) Add the `DemoAppMissing` alert from Module 06 (`absent(up{job="demo-app"})`) to
the PrometheusRule and try again.

### Lab 4 ⭐⭐⭐ — On-call queries
Write the Lesson 7.5 queries yourself. Then cause each problem: a pod that OOMs (limit 20Mi), a pod that can't be
scheduled (request 64 CPUs), a crash loop (`command: ["false"]`) — and find each one with a query and with the built-in
alerts.

---

## ✅ Checkpoint
- [ ] I can install and explain kube-prometheus-stack and what each component monitors
- [ ] I can scrape an app with a ServiceMonitor and ship rules and dashboards as Kubernetes objects
- [ ] I know the release-label selector gotcha
- [ ] I can find restarts, OOMKills, pending pods and throttling with PromQL
- [ ] I validate manifests, rules and Helm values before applying

👉 Next: [Module 08 — Monitoring Capstone](../08-capstone/README.md)
