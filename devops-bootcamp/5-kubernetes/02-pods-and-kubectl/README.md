# Kubernetes Module 02 — Pods & kubectl 🟢

## 🎯 Objectives
- Write a Pod manifest in YAML and `kubectl apply` it
- Use the everyday debugging commands: `get`, `describe`, `logs`, `exec`, `port-forward`
- Use **labels** and **selectors**
- Load your own images into kind
- Understand multi-container pods: sidecars and init containers

## 🧠 Why DevOps engineers care
Everything in Kubernetes runs in pods, and 80% of day-to-day Kubernetes work is "why isn't my pod
working?". The commands in this module are the ones you'll type every single day.

---

## 📖 Lesson 2.1 — Anatomy of a manifest

Every Kubernetes object has the same four top-level fields:

```yaml
apiVersion: v1          # which API group/version defines this kind
kind: Pod               # what type of object
metadata:               # identity: name, namespace, labels, annotations
  name: demo
  labels:
    app: demo
spec:                   # the DESIRED state (what you want)
  containers:
    - name: app
      image: demo-app:1.0.0
      ports:
        - containerPort: 8000
# status:               # the ACTUAL state — written by Kubernetes, never by you
```

## 📖 Lesson 2.2 — Load your image into kind

Your kind cluster can't see images on your laptop's Docker by default. Load them in:

```bash
cd ~/Practice/devops-bootcamp/4-docker/03-dockerfile/solutions
docker build -t demo-app:1.0.0 --build-arg VERSION=1.0.0 demo-app
kind load docker-image demo-app:1.0.0 --name lab
```

> Use a **specific tag** (not `latest`) — with `latest`, Kubernetes always tries to pull from a registry
> and fails with `ErrImagePull`. Or set `imagePullPolicy: IfNotPresent`.

## 📖 Lesson 2.3 — Create, inspect, delete

```bash
kubectl apply -f pod.yaml          # create OR update from the file (declarative ✅)
kubectl get pods                   # STATUS should become Running
kubectl get pod demo -o wide       # which node, which IP
kubectl describe pod demo          # details + EVENTS at the bottom (read these first when debugging!)
kubectl get pod demo -o yaml       # the full object, including status
kubectl delete -f pod.yaml         # delete what the file describes
```

`kubectl apply` is **idempotent**: run it 10 times, you get the same result. Edit the file and apply
again to change things (some pod fields can't change in place — you'll use Deployments for that).

## 📖 Lesson 2.4 — The debugging toolkit ⭐

```bash
kubectl logs demo                  # container stdout/stderr
kubectl logs demo -f               # follow
kubectl logs demo --previous       # logs of the PREVIOUS (crashed) container ← vital for CrashLoopBackOff
kubectl logs demo -c sidecar       # pick a container in a multi-container pod

kubectl exec demo -- env           # run a command inside
kubectl exec -it demo -- sh        # interactive shell

kubectl port-forward pod/demo 8000:8000     # localhost:8000 → the pod (great for quick tests)
curl localhost:8000/health

kubectl get events --sort-by=.lastTimestamp # recent cluster events
kubectl get pods -w                # watch changes live
```

Pod status cheat sheet:

| STATUS | Meaning | First thing to check |
|--------|---------|----------------------|
| `Pending` | not scheduled yet | `describe` → events (not enough CPU/memory? volume?) |
| `ContainerCreating` | pulling image / mounting volumes | `describe` → events |
| `ErrImagePull` / `ImagePullBackOff` | can't get the image | image name/tag typo, private registry, not `kind load`ed |
| `CrashLoopBackOff` | container keeps exiting | `logs --previous` |
| `Running` | at least one container running | `logs`, readiness (Module 07) |
| `Completed` | all containers exited with 0 | normal for jobs |
| `OOMKilled` (in describe) | exceeded memory limit | raise the limit or fix the leak |

## 📖 Lesson 2.5 — Labels and selectors

Labels are key/value tags. **Everything** in Kubernetes connects through them (Deployments find their
pods, Services find their backends) — not through names.

```yaml
metadata:
  labels:
    app: demo
    tier: backend
    env: dev
```
```bash
kubectl get pods --show-labels
kubectl get pods -l app=demo                    # equality
kubectl get pods -l 'env in (dev,staging)'      # set-based
kubectl get pods -l app=demo,tier!=frontend
kubectl label pod demo owner=platform           # add a label
kubectl label pod demo owner-                   # remove it
kubectl delete pods -l app=demo                 # act on everything matching
```

Annotations are for non-identifying metadata (descriptions, tool settings): `kubectl annotate pod demo note="testing"`.

## 📖 Lesson 2.6 — Multi-container pods

Containers in the same pod share the **network** (same IP, talk via `localhost`) and can share
**volumes**. Two common patterns:

**Sidecar** — a helper running alongside the app (log shipper, proxy):
```yaml
spec:
  volumes:
    - name: logs
      emptyDir: {}                      # scratch volume that lives as long as the pod
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh", "-c", "while true; do date >> /logs/app.log; sleep 2; done"]
      volumeMounts: [{ name: logs, mountPath: /logs }]
    - name: log-shipper
      image: busybox:1.36
      command: ["sh", "-c", "tail -F /logs/app.log"]
      volumeMounts: [{ name: logs, mountPath: /logs }]
```

**Init container** — runs to completion **before** the app starts (wait for a dependency, prepare files):
```yaml
spec:
  initContainers:
    - name: wait-for-redis
      image: busybox:1.36
      command: ["sh", "-c", "until nc -z redis 6379; do echo waiting; sleep 2; done"]
  containers:
    - name: app
      image: demo-app:1.0.0
```

## 📖 Lesson 2.7 — Imperative shortcuts (to generate YAML)

Don't write YAML from scratch — generate a skeleton and edit it:
```bash
kubectl run demo --image=demo-app:1.0.0 --port=8000 --dry-run=client -o yaml > pod.yaml
```

> Bare pods are **not** recreated if they die or their node fails. In real life you almost always use a
> **Deployment** (Module 03), which creates pods for you.

---

## ⚠️ Common mistakes
- YAML indentation errors → `kubectl apply` complains about unknown fields; use 2 spaces, never tabs
- Using `:latest` for local images → `ImagePullBackOff`
- Looking at `logs` of a crash-looping pod without `--previous`
- Not reading the **Events** section of `describe`
- Creating bare pods in production

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐ — Run demo-app in a pod
Load `demo-app:1.0.0` into kind, write `pod.yaml` with labels `app: demo` and `tier: backend`, apply it,
port-forward to it and `curl /` — the hostname in the reply is the **pod name**. Then delete it.

### Lab 2 ⭐ — Break it on purpose
Create three broken pods and diagnose each with `get`, `describe` and `logs`:
(a) image `demo-app:does-not-exist`, (b) a container whose command is `sh -c "echo bye; exit 1"`,
(c) a pod requesting `cpu: "64"`. Write down the STATUS and the event that explains each.

### Lab 3 ⭐⭐ — Sidecar
Apply `sidecar-pod.yaml`, then show the shipper's logs with `kubectl logs ... -c log-shipper -f`.
`exec` into the app container and prove both containers see the same file.

### Lab 4 ⭐⭐ — Init container
Apply `init-pod.yaml` (it waits for a service called `redis`). Watch it stay in `Init:0/1`, then create
Redis with `kubectl run redis --image=redis:7-alpine --port=6379 && kubectl expose pod redis --port=6379`
and watch the app start.

---

## ✅ Checkpoint
- [ ] I can write a pod manifest and explain apiVersion/kind/metadata/spec/status
- [ ] I can load local images into kind
- [ ] I debug with `describe` (events), `logs --previous`, `exec`, `port-forward`
- [ ] I select resources with labels

👉 Next: [Module 03 — Deployments & Rollouts](../03-deployments-and-rollouts/README.md)
