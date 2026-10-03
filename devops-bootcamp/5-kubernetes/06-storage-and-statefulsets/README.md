# Kubernetes Module 06 — Storage & StatefulSets 🔴

## 🎯 Objectives
- Understand Volumes, **PersistentVolumes**, **PersistentVolumeClaims** and **StorageClasses**
- Get storage dynamically with a PVC
- Run a database with a **StatefulSet**: stable names, stable storage, ordered startup
- Use a **headless Service** for stable per-pod DNS
- Back up data from a volume with a Job

## 🧠 Why DevOps engineers care
Pods are disposable, but data isn't. When a database pod moves to another node, its data has to follow.
Kubernetes storage is the bridge between your workloads and real disks (AWS EBS, GCP persistent disks,
NFS...). Even if you use managed databases in production, you'll run stateful things (Redis, queues,
monitoring) in clusters — and you must not lose their data.

---

## 📖 Lesson 6.1 — The storage objects

```
 Pod ──uses──► PersistentVolumeClaim ("I need 1Gi, ReadWriteOnce")
                       │ bound to
                       ▼
               PersistentVolume (an actual piece of storage: EBS disk, NFS share, local path...)
                       ▲ created automatically by
               StorageClass ("standard": how to provision disks — the provisioner + parameters)
```

| Object | Who creates it | Scope |
|--------|----------------|-------|
| `StorageClass` | cluster admin (kind ships one called `standard`) | cluster |
| `PersistentVolume` (PV) | usually **automatically** (dynamic provisioning) | cluster |
| `PersistentVolumeClaim` (PVC) | **you**, in your namespace | namespace |

```bash
kubectl get storageclass     # standard (default)   rancher.io/local-path   WaitForFirstConsumer
```
`WaitForFirstConsumer` = the volume is created only when a pod using it is scheduled (so it's on the right node).

## 📖 Lesson 6.2 — A PVC and a pod using it

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
spec:
  containers:
    - name: writer
      image: busybox:1.36
      command: ["sh", "-c", "date >> /data/log.txt; cat /data/log.txt; sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data
```
Delete the pod, create it again: the file still has the old lines. Delete the **PVC** and the data is gone
(with the default `reclaimPolicy: Delete`).

| Access mode | Meaning |
|-------------|---------|
| `ReadWriteOnce` (RWO) | one **node** can mount read-write (block disks: EBS, local) — most common |
| `ReadWriteOncePod` | exactly one pod |
| `ReadOnlyMany` (ROX) | many nodes, read-only |
| `ReadWriteMany` (RWX) | many nodes read-write — needs NFS/EFS/CephFS |

## 📖 Lesson 6.3 — StatefulSets

A Deployment's pods are interchangeable (`demo-7d9f8-abcde`). A **StatefulSet** gives each pod:
- a **stable name**: `redis-0`, `redis-1`, ... (same name after restarts)
- its **own PVC** (`data-redis-0`, `data-redis-1`) that follows it
- **ordered** start/stop (0, then 1, then 2) and a stable DNS name via a headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  clusterIP: None              # headless: DNS returns pod IPs; gives redis-0.redis per-pod names
  selector:
    app: redis
  ports:
    - port: 6379
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: redis           # the headless Service above
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7-alpine
          args: ["redis-server", "--appendonly", "yes"]
          ports:
            - containerPort: 6379
          volumeMounts:
            - name: data
              mountPath: /data
  volumeClaimTemplates:        # one PVC per pod, created automatically
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

```bash
kubectl apply -f redis.yaml
kubectl get sts,pods,pvc -l app=redis
kubectl exec redis-0 -- redis-cli SET greeting hello
kubectl delete pod redis-0                     # Kubernetes recreates redis-0 (same name)...
kubectl exec redis-0 -- redis-cli GET greeting # ...with the same PVC → "hello" ✅
```

Per-pod DNS: `redis-0.redis.default.svc.cluster.local`. Clients that only need "a" Redis use `redis`.

> ⚠️ Scaling a StatefulSet **down** does not delete the PVCs (on purpose — data safety). Clean them up
> yourself when you really mean it.

## 📖 Lesson 6.4 — demo-app + persistent Redis

Point demo-app at Redis with `REDIS_HOST=redis`. Now `/visits` survives **everything**: demo-app
rollouts, Redis pod restarts, even moving Redis to another node (as long as the volume can follow).

## 📖 Lesson 6.5 — Backing up a volume with a Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: redis-backup
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: backup
          image: redis:7-alpine
          command: ["sh", "-c", "redis-cli -h redis --rdb /backup/dump-$(date +%Y%m%d-%H%M%S).rdb && ls -l /backup"]
          volumeMounts:
            - name: backup
              mountPath: /backup
      volumes:
        - name: backup
          persistentVolumeClaim:
            claimName: redis-backups
```
Wrap it in a **CronJob** for nightly backups. In the cloud you'd also use **VolumeSnapshots** and copy
backups off the cluster (object storage) — a backup on the same disk isn't a backup.

## 📖 Lesson 6.6 — Should the database run in Kubernetes?

| Option | Pros | Cons |
|--------|------|------|
| **Managed DB** (RDS, Cloud SQL) | backups, failover, patching done for you | cost, less control |
| **StatefulSet** you write | full control, cheap | YOU handle backups, upgrades, failover |
| **Operator** (CloudNativePG, Redis operator) | automates replication, failover, backups | another tool to learn |

Common team rule: **production databases → managed service or operator**; caches/queues/dev databases →
StatefulSets are fine.

---

## ⚠️ Common mistakes
- Running a database as a **Deployment** with a shared PVC → two pods writing the same files = corruption
- Deleting PVCs while cleaning up → data loss
- Using RWX expecting it to work on block storage (it won't bind — check `kubectl describe pvc`)
- PVC stuck `Pending` with `WaitForFirstConsumer` — normal until a pod uses it
- No backups, or backups stored on the same disk

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐ — Data that survives
Create the `data` PVC and the `writer` pod. Delete and recreate the pod three times — the log grows. Find
the PV that was created and where kind stored it on the node (`kubectl get pv -o yaml` → `hostPath`).

### Lab 2 ⭐⭐ — Redis StatefulSet
Deploy Redis as a StatefulSet. Write a key, delete the pod, read the key back. Scale to 3 replicas and
show the three pods, three PVCs and per-pod DNS names (`nslookup redis` from a busybox pod).
Scale back to 1 — what happens to the PVCs?

### Lab 3 ⭐⭐ — demo-app + Redis
Deploy demo-app (Module 03) with `REDIS_HOST=redis`. Hit `/visits` via port-forward 5 times. Roll out a
new demo-app version and delete `redis-0` — the counter keeps going.

### Lab 4 ⭐⭐⭐ — Backups
Create the `redis-backups` PVC and run the backup Job; list the backup file. Turn it into a CronJob every
5 minutes, wait for two runs, and write `restore_check.sh` that copies the newest `.rdb` out with
`kubectl cp` (via a helper pod) and verifies it with `redis-check-rdb`.

---

## ✅ Checkpoint
- [ ] I can explain StorageClass → PV → PVC → Pod
- [ ] I know RWO vs RWX and when PVCs stay Pending
- [ ] I can run a StatefulSet with volumeClaimTemplates and a headless Service
- [ ] I can back up a volume and I know PVCs survive scale-down

👉 Next: [Module 07 — Probes, Resources & Autoscaling](../07-probes-resources-autoscaling/README.md)
