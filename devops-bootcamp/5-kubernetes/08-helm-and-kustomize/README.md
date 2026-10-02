# Kubernetes Module 08 — Helm & Kustomize 🔴

## 🎯 Objectives
- Stop copy-pasting YAML per environment
- Use **Kustomize**: a base + overlays for dev and prod (built into `kubectl`)
- Use **Helm**: install public charts, and write your own chart for demo-app
- Upgrade and roll back Helm releases
- Choose between Helm and Kustomize

## 🧠 Why DevOps engineers care
Real apps have dev, staging and prod — the same manifests with different replicas, images, resources and
hostnames. Copying YAML three times guarantees they drift apart. Helm and Kustomize are the two standard
answers, and you'll meet both in every Kubernetes job (Argo CD and Flux, the GitOps tools, use them too).

---

## 📖 Lesson 8.1 — Kustomize: base + overlays

```
kustomize/
├── base/                     # what's common everywhere
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/kustomization.yaml     # "base, but 1 replica, namespace dev, DEV message"
    └── prod/kustomization.yaml    # "base, but 3 replicas, namespace prod, bigger resources, image 2.0.0"
```

`base/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
labels:
  - pairs:
      app.kubernetes.io/name: demo
configMapGenerator:            # builds a ConfigMap with a HASH suffix: demo-config-7c9bt8f2
  - name: demo-config
    literals:
      - APP_MESSAGE=Hello from the base
```

`overlays/prod/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: prod
resources:
  - ../../base
images:
  - name: demo-app
    newTag: 2.0.0
replicas:
  - name: demo
    count: 3
configMapGenerator:
  - name: demo-config
    behavior: merge
    literals:
      - APP_MESSAGE=Hello from PROD
patches:
  - target:
      kind: Deployment
      name: demo
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/resources/limits/memory
        value: 256Mi
```

```bash
kubectl kustomize overlays/prod            # print the final YAML (review it!)
kubectl apply -k overlays/dev              # build + apply in one step
kubectl diff -k overlays/prod              # what WOULD change in the cluster
```

Why the ConfigMap hash matters: changing `APP_MESSAGE` changes the ConfigMap **name**, which changes the
Deployment's pod template → an automatic rolling update. Config changes roll out (and roll back) like code.

## 📖 Lesson 8.2 — Helm: the package manager

A **chart** is a package of templated manifests + default **values**. A **release** is one installed
copy of a chart. Helm tracks release history, so upgrades and rollbacks are one command.

Installing someone else's chart:
```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm search repo traefik
helm show values traefik/traefik | less        # every setting you can change
helm install traefik traefik/traefik -n traefik --create-namespace --set ingressClass.isDefaultClass=true
helm list -A
```

## 📖 Lesson 8.3 — Write your own chart

```bash
helm create demo-app        # generates a full example chart — read it, then simplify
```
Structure (see [`solutions/demo-app-chart/`](solutions/demo-app-chart/)):
```
demo-app-chart/
├── Chart.yaml              # name, version (of the chart), appVersion (of the app)
├── values.yaml             # defaults
├── values-prod.yaml        # overrides for prod
└── templates/
    ├── _helpers.tpl        # reusable snippets (names, labels)
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── ingress.yaml        # only rendered if ingress.enabled
    ├── hpa.yaml            # only rendered if autoscaling.enabled
    └── NOTES.txt           # printed after install
```

Templates use Go templating with values:
```yaml
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
{{- if .Values.ingress.enabled }}
...
{{- end }}
```

## 📖 Lesson 8.4 — The Helm workflow

```bash
helm lint ./demo-app-chart                                    # catch mistakes
helm template demo ./demo-app-chart -f values-prod.yaml       # render locally — review the YAML
helm install demo ./demo-app-chart -n dev --create-namespace  # install
helm upgrade demo ./demo-app-chart -n dev --set image.tag=2.0.0 --wait   # upgrade, wait for ready
helm history demo -n dev
helm rollback demo 1 -n dev                                   # back to revision 1
helm upgrade --install demo ./demo-app-chart -n prod -f values-prod.yaml --wait --atomic
#            ^ install if missing, upgrade if present             ^ auto-rollback if it fails ✅
helm uninstall demo -n dev
```

`--atomic` + readiness probes = a failed upgrade is rolled back automatically. This is the line most CI/CD
pipelines run.

## 📖 Lesson 8.5 — Helm or Kustomize?

| | Kustomize | Helm |
|--|-----------|------|
| Approach | patch plain YAML | templates + values |
| Learning curve | low | medium (Go templates) |
| Packaging/sharing apps | no | yes — the standard for third-party software |
| Release history/rollback | no (use Git) | yes |
| Typical use | your own apps, environment overlays | installing third-party apps; your apps too |

Many teams use **both**: Helm for third-party charts (Traefik, Prometheus, cert-manager), Kustomize or Helm
for their own apps — all applied by a GitOps tool (Argo CD / Flux) from Git.

---

## ⚠️ Common mistakes
- Not looking at rendered output before applying (`kubectl kustomize`, `helm template`)
- Indentation bugs in templates — use `nindent` and `toYaml`
- Changing chart templates without bumping `version` in `Chart.yaml`
- Putting secrets in `values.yaml` in Git
- Mixing `kubectl edit` with Helm-managed resources — Helm will overwrite your edits on the next upgrade

---

## 🧪 Labs
Everything is in [`solutions/`](solutions/). Validate with `./validate.sh` there.

### Lab 1 ⭐⭐ — Kustomize overlays
Build the base + `dev` + `prod` overlays. Show the differences with
`diff <(kubectl kustomize overlays/dev) <(kubectl kustomize overlays/prod)`. Apply both into
namespaces `dev` and `prod`. Change the prod message and watch a rollout happen because of the hash.

### Lab 2 ⭐⭐ — Install a public chart
Remove the Traefik you installed from YAML in Module 04 and install it with the official Helm chart
instead. Compare: how many resources did the chart create?

### Lab 3 ⭐⭐⭐ — Your own chart
Study `demo-app-chart/`. `helm lint` it, render it with and without `values-prod.yaml`, then install it as
`demo` in namespace `helm-dev`. Upgrade to `image.tag=2.0.0`, check `helm history`, roll back to 1.

### Lab 4 ⭐⭐⭐ — Atomic upgrade
Upgrade with `--atomic --timeout 60s --set image.tag=9.9.9` (an image that doesn't exist). Watch Helm roll
back automatically, then show `helm history` explaining what happened.

---

## ✅ Checkpoint
- [ ] I can build Kustomize overlays and explain configMapGenerator hashes
- [ ] I can install, upgrade, roll back and uninstall Helm releases
- [ ] I can read and write a basic chart (`values`, `if`, `toYaml`, `nindent`, helpers)
- [ ] I review rendered YAML before applying

👉 Next: [Module 09 — Troubleshooting & Security](../09-troubleshooting-and-security/README.md)
