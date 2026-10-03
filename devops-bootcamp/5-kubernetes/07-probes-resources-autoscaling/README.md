# Kubernetes Module 07 — Probes, Resources & Autoscaling 🔴

## 🎯 Objectives
- Tell Kubernetes when your app is alive and ready with **liveness, readiness and startup probes**
- Set CPU/memory **requests and limits**, and understand QoS classes and OOMKills
- Scale automatically with the **HorizontalPodAutoscaler** (HPA)
- Protect availability during maintenance with **PodDisruptionBudgets**
- Spread replicas across nodes

## 🧠 Why DevOps engineers care
Without probes, Kubernetes sends traffic to pods that aren't ready and never restarts frozen ones.
Without requests/limits, one hungry app can take down a whole node. Without autoscaling, you either pay
for idle servers or fall over at peak traffic. These settings are what make a deployment
**production-ready** — reviewers check them first.

---

## 📖 Lesson 7.1 — The three probes

| Probe | Question | If it fails |
|-------|----------|-------------|
| **readiness** | "Can you take traffic right now?" | pod is **removed from Service endpoints** (not restarted) |
| **liveness** | "Are you still working, or stuck?" | container is **restarted** |
| **startup** | "Have you finished starting?" | liveness/readiness are paused until it succeeds (for slow starters) |

```yaml
      containers:
        - name: app
          image: demo-app:1.0.0
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            periodSeconds: 5
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            periodSeconds: 10
            failureThreshold: 3        # restart after ~30s of failures
          startupProbe:
            httpGet:
              path: /health
              port: 8000
            periodSeconds: 2
            failureThreshold: 30       # allow up to 60s to start
```

Probe types: `httpGet`, `tcpSocket` (e.g. Redis on 6379), `exec` (`["redis-cli", "ping"]`), `grpc`.

> ⚠️ Liveness probes should check **only the app itself**, never its dependencies. If the database is
> down and every app pod's liveness fails, Kubernetes restarts everything in a loop and makes the outage
> worse. Dependency checks belong in readiness (or nowhere).

Readiness + rolling updates = safe deploys: a new version that never becomes ready never receives
traffic, and with `maxUnavailable: 0` the old pods keep serving.

## 📖 Lesson 7.2 — Requests and limits

```yaml
          resources:
            requests:            # what the scheduler RESERVES on a node for this container
              cpu: 100m          # 100 millicores = 0.1 CPU
              memory: 64Mi
            limits:              # the hard ceiling
              cpu: 500m          # above this → throttled (slowed down)
              memory: 128Mi      # above this → OOMKilled (killed and restarted)
```

| Setting | Effect |
|---------|--------|
| `requests` | scheduling: a pod only goes on a node with that much unreserved capacity |
| CPU `limit` | throttling — the app gets slower, never killed |
| memory `limit` | **OOMKilled** when exceeded (`kubectl describe pod` → `Last State: OOMKilled`) |

**QoS classes** (who gets evicted first when a node runs out of memory):
- `Guaranteed` — requests == limits for every container (last to be evicted)
- `Burstable` — some requests set
- `BestEffort` — nothing set (**first** to be evicted)

```bash
kubectl get pod <pod> -o jsonpath='{.status.qosClass}'
kubectl top pods          # actual usage (needs metrics-server)
kubectl describe node lab-worker | sed -n '/Allocated resources/,/Events/p'
```

Common practice: always set requests; set memory limits; many teams skip CPU limits (throttling hurts
latency) — follow your platform team's policy. Namespaces can enforce defaults with `LimitRange` and
totals with `ResourceQuota`.

## 📖 Lesson 7.3 — metrics-server (needed for `top` and HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# kind's kubelets use self-signed certificates — allow that (lab only):
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server
kubectl top nodes      # works after ~1 minute
```

## 📖 Lesson 7.4 — HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60       # % of the CPU *request* → requests are REQUIRED for HPA
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 60   # wait a minute before scaling down (avoid flapping)
```

Generate load (demo-app's `/work?ms=200` endpoint keeps a CPU busy for 200 ms per request):
```bash
kubectl run load --image=busybox:1.36 --restart=Never -- \
  sh -c 'while true; do wget -qO- "http://demo/work?ms=200" > /dev/null; done'
kubectl get hpa demo -w            # TARGETS climbs above 60%, REPLICAS goes up
kubectl delete pod load            # load stops → after the stabilization window, replicas go down
```

## 📖 Lesson 7.5 — PodDisruptionBudgets and spreading

A **PDB** limits how many pods can be taken down *voluntarily* at once (node drains during upgrades):
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: demo
spec:
  minAvailable: 1                 # or maxUnavailable: 1
  selector:
    matchLabels:
      app: demo
```
```bash
kubectl drain lab-worker --ignore-daemonsets --delete-emptydir-data   # respects the PDB
kubectl uncordon lab-worker
```

**Spread replicas across nodes** so one node failure doesn't take all of them:
```yaml
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              app: demo
```

---

## ⚠️ Common mistakes
- Liveness probe checking the database → cascading restarts
- No readiness probe → traffic to pods still starting → errors during every deploy
- Liveness `initialDelaySeconds` too short for a slow app → restart loop (use a `startupProbe`)
- HPA without CPU **requests** → `<unknown>` targets
- Memory limit too low → `OOMKilled` / `CrashLoopBackOff`
- `minAvailable` equal to replicas → drains block forever

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐⭐ — Production-ready Deployment
Apply `deployment.yaml` (probes, resources, spread constraints). Check the QoS class. Then break the
readiness path (`/nope`) in a new rollout: the new pod never becomes ready, old pods keep serving, and
`rollout status` times out. Roll back.

### Lab 2 ⭐⭐ — OOMKilled on purpose
Apply `oom-demo.yaml` (a container that allocates more memory than its limit). Find `OOMKilled` in
`describe` and the restart count climbing. Fix it by raising the limit.

### Lab 3 ⭐⭐⭐ — Autoscaling under load
Install metrics-server, apply the HPA, start `load-generator.yaml` and record replicas every 15 s with
`watch_hpa.sh`. Stop the load and watch it scale down. Explain the timeline.

### Lab 4 ⭐⭐ — Safe maintenance
Apply the PDB, scale demo to 3, and `kubectl drain` the node running most demo pods. Show that at least
one pod was always available. `uncordon` the node afterwards.

---

## ✅ Checkpoint
- [ ] I can explain readiness vs liveness vs startup and what each failure does
- [ ] I set requests/limits and know throttling vs OOMKill and the QoS classes
- [ ] I can autoscale with an HPA and explain why requests are required
- [ ] I can protect availability with a PDB and topology spread

👉 Next: [Module 08 — Helm & Kustomize](../08-helm-and-kustomize/README.md)
