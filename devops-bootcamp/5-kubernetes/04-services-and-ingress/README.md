# Kubernetes Module 04 — Services & Ingress 🟡

## 🎯 Objectives
- Give pods a stable address with **Services** (`ClusterIP`, `NodePort`, `LoadBalancer`)
- Use Kubernetes **DNS** to connect services
- Understand `port` vs `targetPort` vs `nodePort`, and endpoints
- Expose apps over HTTP with an **Ingress** and an ingress controller (Traefik)
- Know where things are going: the **Gateway API**

## 🧠 Why DevOps engineers care
Pods come and go, and each new pod gets a new IP. Services give a fixed name and IP that load-balances
across whatever pods currently match. Ingress puts many apps behind one entry point with hostnames and
paths — exactly how real websites and APIs are exposed from a cluster.

---

## 📖 Lesson 4.1 — Why Services exist

```
            Service "demo"  (stable name + virtual IP 10.96.12.34:80)
                 │  selector: app=demo
     ┌───────────┼───────────┐
   Pod 10.244.1.5  Pod 10.244.2.7  Pod 10.244.1.9    ← IPs change on every restart/rollout
```

`service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  type: ClusterIP           # the default: reachable only INSIDE the cluster
  selector:
    app: demo               # send traffic to pods with this label
  ports:
    - name: http
      port: 80              # the Service's port (what clients use)
      targetPort: 8000      # the container's port
```

```bash
kubectl apply -f service.yaml
kubectl get svc demo
kubectl get endpointslices -l kubernetes.io/service-name=demo   # the pod IPs behind it
kubectl port-forward svc/demo 8080:80 && curl localhost:8080/   # test from your laptop
```

## 📖 Lesson 4.2 — Service DNS

Every Service gets a DNS name:

```
demo                               ← from a pod in the SAME namespace
demo.dev                           ← from another namespace (service.namespace)
demo.dev.svc.cluster.local         ← fully qualified
```

```bash
kubectl run tmp --rm -it --image=busybox:1.36 --restart=Never -- sh
/ # wget -qO- http://demo/          # load-balanced across demo pods (watch "hostname" change)
/ # nslookup demo
```

This is how demo-app finds Redis: `REDIS_HOST=redis` — exactly like Docker Compose service names.

## 📖 Lesson 4.3 — Service types

| Type | Reachable from | How |
|------|----------------|-----|
| `ClusterIP` | inside the cluster | virtual IP + DNS name |
| `NodePort` | outside, via **any node's IP** | opens a port 30000–32767 on every node |
| `LoadBalancer` | outside, via a **cloud load balancer** | cloud provider creates an LB (AWS ELB, GCP LB...) |
| `ExternalName` | — | DNS alias to an outside name (e.g. a managed database) |
| headless (`clusterIP: None`) | inside | DNS returns the pod IPs directly (StatefulSets, Module 06) |

```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
      nodePort: 30080        # optional; otherwise one is picked for you
```
In kind, NodePorts are reachable on the node containers' IPs (`docker inspect lab-worker`), not on
localhost — that's why we use an ingress on ports 80/443 instead.

## 📖 Lesson 4.4 — Ingress: one entry point, many apps

An **Ingress** is a set of HTTP routing rules. An **ingress controller** (a reverse proxy running in the
cluster) reads them and does the routing. Kubernetes doesn't ship one — you install one.

```
 browser ──► localhost:80 ──► [ Traefik ingress controller ] ──┬─ host demo.localtest.me ─► svc demo
                                                               └─ path /whoami ───────────► svc whoami
```

We use **Traefik** (images on Docker Hub, simple, widely used). Install it with the provided manifest:
```bash
kubectl apply -f solutions/traefik.yaml
kubectl -n traefik rollout status deployment/traefik
```
It runs on the control-plane node and listens on that node's port 80 — which kind maps to your
laptop's port 80 (`extraPortMappings` in Module 01).

`ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
spec:
  ingressClassName: traefik
  rules:
    - host: demo.localtest.me          # *.localtest.me always resolves to 127.0.0.1 — handy for labs
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo
                port:
                  number: 80
```
```bash
kubectl apply -f ingress.yaml
curl http://demo.localtest.me/           # served by demo pods through Traefik
```

Path-based routing on one host:
```yaml
  rules:
    - host: apps.localtest.me
      http:
        paths:
          - path: /demo
            pathType: Prefix
            backend: { service: { name: demo, port: { number: 80 } } }
          - path: /whoami
            pathType: Prefix
            backend: { service: { name: whoami, port: { number: 80 } } }
```

HTTPS: add a `tls:` section pointing at a Secret with a certificate. In real clusters, **cert-manager**
gets free Let's Encrypt certificates automatically.

## 📖 Lesson 4.5 — The future: Gateway API

The **Gateway API** is the official successor to Ingress — more expressive (traffic splitting, header
matching, TCP/gRPC) and with clearer roles (platform team owns the `Gateway`, app teams own `HTTPRoute`s).
The popular `ingress-nginx` controller was retired in early 2026, and many teams are moving to Gateway API.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: demo
spec:
  parentRefs:
    - name: main-gateway              # a Gateway created by the platform team
  hostnames: ["demo.localtest.me"]
  rules:
    - backendRefs:
        - name: demo
          port: 80
          weight: 90                  # 90% to stable...
        - name: demo-canary
          port: 80
          weight: 10                  # ...10% to the canary — built in!
```
Learn Ingress first (it's everywhere), then Gateway API. Traefik supports both.

---

## ⚠️ Common mistakes
- Service `selector` doesn't match the pod labels → **no endpoints** → connection refused. Check
  `kubectl get endpointslices -l kubernetes.io/service-name=<svc>`
- `targetPort` ≠ the port the app listens on
- Forgetting `ingressClassName` → no controller picks the Ingress up
- Using `NodePort`/`LoadBalancer` for every service — internal services should stay `ClusterIP`

---

## 🧪 Labs
Manifests in [`solutions/`](solutions/). Use the Module 03 `deployment.yaml` for demo-app.

### Lab 1 ⭐ — ClusterIP + DNS
Create the `demo` Service. From a temporary busybox pod, call `http://demo/` 10 times and show several
different hostnames answered. Then break the Service selector on purpose and show the empty endpoints.

### Lab 2 ⭐⭐ — Ingress with Traefik
Install Traefik, create the Ingress for `demo.localtest.me`, and `curl` it from your laptop. Then add the
`whoami` app (`traefik/whoami:v1.10` — it echoes request details) and route `/whoami` on
`apps.localtest.me` to it.

### Lab 3 ⭐⭐ — Two versions, two hostnames
Run demo-app 1.0.0 as `demo-v1` and 2.0.0 as `demo-v2` (two Deployments + Services) and route
`v1.localtest.me` and `v2.localtest.me` to each. This is how you preview a release before switching.

### Lab 4 ⭐⭐⭐ — Connectivity checker
`svc_check.sh SERVICE [NAMESPACE]` prints the Service type/ports, its endpoint IPs, the pods matching its
selector (and warns if the counts differ), and finally does an in-cluster `wget` from a throwaway pod.

---

## ✅ Checkpoint
- [ ] I can explain why Services exist and how selectors connect them to pods
- [ ] I know `port`/`targetPort`/`nodePort` and the four Service types
- [ ] I can reach services by DNS name across namespaces
- [ ] I can expose an app with an Ingress and know what the Gateway API adds

👉 Next: [Module 05 — ConfigMaps & Secrets](../05-configmaps-and-secrets/README.md)
