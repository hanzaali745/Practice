# Kubernetes Module 05 — ConfigMaps & Secrets 🟡

## 🎯 Objectives
- Keep configuration **out of images** with ConfigMaps
- Store sensitive values in Secrets — and know their limits
- Inject config as **environment variables** or **files**
- Roll out config changes safely
- Know the production options for secrets (Sealed Secrets, External Secrets, Vault)

## 🧠 Why DevOps engineers care
One image should run in dev, staging and prod — only the config changes. Getting config and secrets
right is also where most security incidents start: passwords in Git, in images, or in plain-text YAML.

---

## 📖 Lesson 5.1 — ConfigMaps

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  APP_MESSAGE: "Hello from a ConfigMap"   # simple key/values...
  LOG_LEVEL: "info"
  settings.ini: |                          # ...or whole files
    [server]
    timeout = 30
    workers = 4
```

Create one from the command line (handy to generate YAML):
```bash
kubectl create configmap demo-config --from-literal=LOG_LEVEL=info --from-file=settings.ini \
    --dry-run=client -o yaml > configmap.yaml
```

## 📖 Lesson 5.2 — Using config in a pod

**As environment variables:**
```yaml
      containers:
        - name: app
          image: demo-app:1.0.0
          env:
            - name: APP_MESSAGE              # one key
              valueFrom:
                configMapKeyRef:
                  name: demo-config
                  key: APP_MESSAGE
          envFrom:
            - configMapRef:                  # ALL keys become env vars
                name: demo-config
```

**As files** (each key becomes a file in the mounted folder):
```yaml
          volumeMounts:
            - name: config
              mountPath: /etc/demo           # → /etc/demo/settings.ini, /etc/demo/LOG_LEVEL ...
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: demo-config
            items:                           # optional: only some keys
              - key: settings.ini
                path: settings.ini
```

| | Env vars | Mounted files |
|--|----------|---------------|
| Good for | small values, 12-factor apps | config files (nginx.conf, settings.ini) |
| Updates when the ConfigMap changes? | **no** — needs a pod restart | **yes**, after ~1 minute (unless `subPath` is used) |

## 📖 Lesson 5.3 — Secrets

```bash
kubectl create secret generic demo-secret \
  --from-literal=DB_PASSWORD='S3cure!pass' \
  --from-literal=API_TOKEN='abc123'
kubectl get secret demo-secret -o yaml       # values are base64-encoded...
kubectl get secret demo-secret -o jsonpath='{.data.DB_PASSWORD}' | base64 -d    # ...which anyone can decode!
```

> ⚠️ **base64 is encoding, not encryption.** A Secret is only "secret" because:
> RBAC can restrict who may read it, it's not shown in `describe`, and clusters can encrypt etcd at rest.
> **Never commit Secret YAML with real values to Git.**

Using a Secret is the same as a ConfigMap:
```yaml
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: demo-secret
                  key: DB_PASSWORD
          # or mount as files (common for TLS certs and credential files):
          volumeMounts:
            - name: secrets
              mountPath: /run/secrets
              readOnly: true
      volumes:
        - name: secrets
          secret:
            secretName: demo-secret
            defaultMode: 0400
```

Other Secret types: `kubernetes.io/tls` (`kubectl create secret tls`), `kubernetes.io/dockerconfigjson`
(`kubectl create secret docker-registry` — for pulling from private registries via `imagePullSecrets`).

## 📖 Lesson 5.4 — Rolling out config changes

Pods don't restart when a ConfigMap/Secret changes. Options:

```bash
kubectl apply -f configmap.yaml
kubectl rollout restart deployment/demo      # simplest: restart pods so they read the new values
```

Better — make config changes **visible to the Deployment** so they trigger a normal rollout (and a
rollback restores the old config too). Kustomize does this automatically by adding a hash to the
ConfigMap name (`demo-config-7g8h9k`) — you'll use that in Module 08. Helm charts often use a checksum
annotation on the pod template.

`immutable: true` on a ConfigMap/Secret prevents accidental edits (and is faster for the cluster) —
you then create a new one for each change.

## 📖 Lesson 5.5 — Secrets in real life

Plain Secrets in Git are not acceptable. Common solutions:

| Tool | Idea |
|------|------|
| **Sealed Secrets** | encrypt the Secret with the cluster's public key → safe to commit; only the cluster can decrypt |
| **External Secrets Operator** | Secrets are synced from AWS Secrets Manager / GCP Secret Manager / Vault |
| **HashiCorp Vault** | a dedicated secrets server; apps or sidecars fetch secrets at runtime |
| **SOPS** | encrypt YAML values with KMS/age keys; used with Helm/Kustomize/Argo CD |

For this course: create Secrets with `kubectl create secret` from values in environment variables,
never from files in Git.

---

## ⚠️ Common mistakes
- Baking config into images → a rebuild for every config change
- Thinking base64 = encrypted; committing Secret YAML
- Expecting env vars to update when the ConfigMap changes
- Typos in `configMapKeyRef` names → pod stuck in `CreateContainerConfigError` (check `describe`)
- Printing secrets in logs (`env` in debug output!)

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐ — Configure demo-app
Create `demo-config` with `APP_MESSAGE` and use `envFrom` in the demo Deployment. Call `/` and see the
message. Change it, apply, see it **not** change, then `rollout restart` and see it change.

### Lab 2 ⭐⭐ — Config files
Mount `settings.ini` from the ConfigMap into `/etc/demo`. `exec` into a pod and `cat` it. Edit the
ConfigMap and watch the file change inside the running pod within ~1 minute (no restart).

### Lab 3 ⭐⭐ — Secrets done safely
Write `make_secret.sh` that reads `DB_PASSWORD` and `API_TOKEN` from environment variables (fails if
they're missing) and creates/updates the Secret idempotently with
`kubectl create secret ... --dry-run=client -o yaml | kubectl apply -f -`. Mount it read-only at
`/run/secrets` with mode `0400`, and prove `kubectl describe secret` doesn't show values.

### Lab 4 ⭐⭐⭐ — Find the mistake
Apply `broken-config.yaml` (it references a key that doesn't exist). Find the status and the exact
error event, fix it, and explain how to make such mistakes fail at **deploy** time in CI (hint: validate
manifests and/or use `optional: false` + a dry-run against the cluster).

---

## ✅ Checkpoint
- [ ] I can inject config as env vars and as files, and know which ones update live
- [ ] I know Secrets are base64, not encrypted, and never commit them
- [ ] I can roll out config changes (`rollout restart`, hashed names)
- [ ] I can name production secret-management options

👉 Next: [Module 06 — Storage & StatefulSets](../06-storage-and-statefulsets/README.md)
