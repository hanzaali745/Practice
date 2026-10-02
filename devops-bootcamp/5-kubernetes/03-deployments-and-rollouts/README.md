# Kubernetes Module 03 — Deployments & Rollouts 🟡

## 🎯 Objectives
- Run apps with **Deployments** (and understand the ReplicaSets they manage)
- Scale up and down
- Ship new versions with **zero-downtime rolling updates**
- Watch, pause, inspect and **roll back** rollouts
- Choose a rollout strategy (`RollingUpdate` vs `Recreate`)

## 🧠 Why DevOps engineers care
"Deploy version 1.4.3 to production with no downtime, and undo it in 10 seconds if it breaks" — that's
the daily job, and Deployments are how Kubernetes does it. Nearly every stateless app you deploy will
be a Deployment.

---

## 📖 Lesson 3.1 — Deployment → ReplicaSet → Pods

```
 Deployment  demo           (you manage this: image, replicas, strategy)
   └── ReplicaSet demo-7d9f8  (manages "exactly N pods of THIS version")
         ├── Pod demo-7d9f8-abcde
         ├── Pod demo-7d9f8-fghij
         └── Pod demo-7d9f8-klmno
```

`deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
  labels:
    app: demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo            # which pods belong to this Deployment...
  template:                # ...and the pod template used to create them
    metadata:
      labels:
        app: demo          # MUST match the selector above
    spec:
      containers:
        - name: app
          image: demo-app:1.0.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          env:
            - name: APP_VERSION
              value: "1.0.0"
```

```bash
kubectl apply -f deployment.yaml
kubectl get deploy,rs,pods -l app=demo
kubectl rollout status deployment/demo        # waits until all replicas are ready
```

## 📖 Lesson 3.2 — Scaling

```bash
kubectl scale deployment demo --replicas=5    # quick, imperative
# or change `replicas: 5` in the YAML and `kubectl apply` again (declarative ✅ — Git stays the truth)
kubectl get pods -l app=demo -o wide          # spread over the worker nodes
```
(Automatic scaling based on CPU comes in Module 07.)

## 📖 Lesson 3.3 — Rolling updates

Change the image (or anything in `template:`) and Kubernetes replaces pods **gradually**: start a new
pod, wait until it's ready, stop an old one, repeat. Users never see downtime.

```bash
docker build -t demo-app:2.0.0 --build-arg VERSION=2.0.0 ~/Practice/devops-bootcamp/4-docker/03-dockerfile/solutions/demo-app
kind load docker-image demo-app:2.0.0 --name lab

# Declarative: edit the image + APP_VERSION in deployment.yaml to 2.0.0, then:
kubectl apply -f deployment.yaml
kubectl rollout status deployment/demo
kubectl get rs -l app=demo          # the OLD ReplicaSet is scaled to 0 (kept for rollbacks)
```

Quick imperative alternative: `kubectl set image deployment/demo app=demo-app:2.0.0`

## 📖 Lesson 3.4 — Controlling the rollout

```yaml
spec:
  replicas: 4
  revisionHistoryLimit: 5          # how many old ReplicaSets to keep for rollbacks
  minReadySeconds: 5               # a new pod must stay ready this long before counting as "available"
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1                  # at most 1 EXTRA pod during the update (4+1 = 5 max)
      maxUnavailable: 0            # never go below 4 ready pods → zero downtime
```

| Strategy | Behaviour | Use when |
|----------|-----------|----------|
| `RollingUpdate` (default) | gradual replacement, old + new run side by side | almost always |
| `Recreate` | kill **all** old pods, then start new ones (downtime!) | the app can't run two versions at once (e.g. a DB schema lock) |

## 📖 Lesson 3.5 — History and rollback

```bash
kubectl rollout history deployment/demo
kubectl annotate deployment/demo kubernetes.io/change-cause="deploy 2.0.0: new greeting"   # shows in history
kubectl rollout undo deployment/demo                  # back to the previous revision
kubectl rollout undo deployment/demo --to-revision=1  # back to a specific one
kubectl rollout pause deployment/demo                 # stop mid-rollout (to inspect a canary)
kubectl rollout resume deployment/demo
kubectl rollout restart deployment/demo               # re-create all pods (e.g. to pick up new config)
```

> After an `undo`, your YAML in Git no longer matches the cluster. Fix the YAML (or revert the commit)
> right away — **Git should always describe what's running.**

## 📖 Lesson 3.6 — A broken rollout (and why it's safe)

Deploy an image that doesn't exist:
```bash
kubectl set image deployment/demo app=demo-app:9.9.9
kubectl rollout status deployment/demo --timeout=60s    # never finishes → exit code 1
kubectl get pods -l app=demo                             # new pod: ImagePullBackOff; OLD pods still Running ✅
kubectl rollout undo deployment/demo
```
With `maxUnavailable: 0`, a bad version can never take down the running one. Combined with readiness
probes (Module 07), the same protects you from versions that start but don't work.

## 📖 Lesson 3.7 — Other workload types (preview)

| Kind | For |
|------|-----|
| **Deployment** | stateless apps (web, APIs) ✅ |
| **StatefulSet** | databases, things needing stable names + storage (Module 06) |
| **DaemonSet** | one pod on **every** node (log collectors, monitoring agents) |
| **Job** | run to completion once (migrations, batch jobs) |
| **CronJob** | a Job on a schedule (backups, reports) |

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report
spec:
  schedule: "*/5 * * * *"            # same syntax as cron (Shell Module 09)
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: report
              image: busybox:1.36
              command: ["sh", "-c", "date; echo generating report"]
```

---

## ⚠️ Common mistakes
- `selector.matchLabels` not matching `template.metadata.labels` → apply is rejected
- Using `latest`: changing nothing in the YAML means **no rollout** happens even if the image changed
- `kubectl edit`/`set image` in production and forgetting to update Git
- `maxUnavailable` too high → capacity drops during deploys
- Expecting `rollout undo` to also roll back ConfigMaps/Secrets (it doesn't)

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐ — Deploy and scale
Deploy demo-app with 3 replicas, see the Deployment/ReplicaSet/Pods chain, scale to 6 and back to 2.
Use `kubectl get pods -o wide` to see which nodes they landed on.

### Lab 2 ⭐⭐ — Zero-downtime upgrade
Set `maxSurge: 1`, `maxUnavailable: 0`, `minReadySeconds: 3`. In one terminal run a loop that calls the
service every 0.2s (`kubectl port-forward deploy/demo 8000:8000` + `curl`) printing the version; in
another, roll out 2.0.0. Watch the versions switch with **no failed requests**.

### Lab 3 ⭐⭐ — Rollback drill
Deploy 1.0.0 → 2.0.0 → the broken 9.9.9 (with change-cause annotations). Show the history, prove the old
pods kept serving during the broken rollout, then undo back to 2.0.0 and finally `--to-revision` 1.

### Lab 4 ⭐⭐⭐ — Deploy script with automatic rollback
`k8s_deploy.sh IMAGE_TAG` sets the image, waits with `kubectl rollout status --timeout`, and on failure
runs `kubectl rollout undo` and exits 1 — the same idea as the Docker capstone, Kubernetes-style.
Also add a CronJob that prints the date every minute and check its Jobs/pods/logs.

---

## ✅ Checkpoint
- [ ] I can explain Deployment → ReplicaSet → Pod
- [ ] I can scale, roll out, watch, pause and roll back
- [ ] I can configure `maxSurge`/`maxUnavailable` for zero downtime
- [ ] I know when to use Deployment vs StatefulSet vs DaemonSet vs Job/CronJob

👉 Next: [Module 04 — Services & Ingress](../04-services-and-ingress/README.md)
