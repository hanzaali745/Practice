# Kubernetes Module 09 — Troubleshooting & Security 🔴

## 🎯 Objectives
- Debug any broken workload with a repeatable method
- Control **who can do what** with RBAC (ServiceAccounts, Roles, RoleBindings)
- Run pods securely with `securityContext` and **Pod Security Standards**
- Restrict pod-to-pod traffic with **NetworkPolicies**
- Isolate teams/environments with namespaces and quotas

## 🧠 Why DevOps engineers care
When production breaks at 3 a.m., a calm, systematic debugging method is worth more than any tool. And
most cluster security incidents come from three gaps: too much access (RBAC), containers running as
root (securityContext), and every pod able to talk to every other pod (NetworkPolicy). This module closes
all three.

---

## 📖 Lesson 9.1 — The troubleshooting method

Work **top-down**, from the symptom to the cause:

```
1. What's wrong?          kubectl get pods,deploy,svc,ingress -n <ns>
2. Pod not Running?       kubectl describe pod <pod>      → read EVENTS at the bottom
3. Crashing?              kubectl logs <pod> --previous
4. Running but broken?    kubectl logs <pod> ; kubectl exec -it <pod> -- sh
5. Service unreachable?   kubectl get endpointslices -l kubernetes.io/service-name=<svc>
                          (empty → selector/labels or readiness problem)
6. Ingress 404/502?       kubectl describe ingress <ing> ; controller logs
7. Cluster-wide?          kubectl get events -A --sort-by=.lastTimestamp ; kubectl get nodes ; kubectl top nodes
```

| Symptom | Usual cause | Where to look |
|---------|-------------|---------------|
| `Pending` | no node has enough CPU/memory; PVC not bound; nodeSelector/taints | `describe pod` events |
| `ImagePullBackOff` | wrong image/tag, private registry without `imagePullSecrets`, not loaded into kind | `describe pod` |
| `CrashLoopBackOff` | app exits: bad config, missing env var, can't reach a dependency | `logs --previous` |
| `CreateContainerConfigError` | missing ConfigMap/Secret or key | `describe pod` |
| `OOMKilled` | memory limit too low / leak | `describe pod` → Last State |
| Running but 0/1 READY | readiness probe failing | `describe pod` → probe events |
| Service: connection refused | no endpoints (selector mismatch / not ready), wrong `targetPort` | endpointslices |

**Handy debugging tools:**
```bash
kubectl run debug --rm -it --image=nicolaka/netshoot -- bash      # curl, dig, nc, tcpdump...
kubectl debug -it <pod> --image=busybox:1.36 --target=app          # attach a debug container to a running pod
kubectl get pod <pod> -o yaml | less                               # the whole truth
kubectl auth can-i <verb> <resource> --as=<user>                   # RBAC questions
```

## 📖 Lesson 9.2 — RBAC: who can do what

```
 subject (User / Group / ServiceAccount) ──RoleBinding──► Role (rules: verbs on resources, in ONE namespace)
                                         ──ClusterRoleBinding──► ClusterRole (cluster-wide)
```

A read-only role for a CI deployer's ServiceAccount:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: viewer
  namespace: dev
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-reads-pods
  namespace: dev
subjects:
  - kind: ServiceAccount
    name: viewer
    namespace: dev
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
```bash
kubectl auth can-i list pods -n dev --as=system:serviceaccount:dev:viewer      # yes
kubectl auth can-i delete pods -n dev --as=system:serviceaccount:dev:viewer    # no
kubectl auth can-i list pods -n prod --as=system:serviceaccount:dev:viewer     # no
```
Principle of **least privilege**: give exactly what's needed, in the narrowest namespace. Pods that don't
call the Kubernetes API should set `automountServiceAccountToken: false`.

## 📖 Lesson 9.3 — Secure pods: securityContext

```yaml
spec:
  automountServiceAccountToken: false
  securityContext:                    # pod level
    runAsNonRoot: true
    runAsUser: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      securityContext:                # container level
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
```
Same ideas as Docker Module 06 (`--read-only --cap-drop ALL --security-opt no-new-privileges`), now
enforced by Kubernetes.

**Pod Security Standards** let a namespace *require* this. Label the namespace:
```bash
kubectl label namespace secure pod-security.kubernetes.io/enforce=restricted
```
Now pods that run as root or keep capabilities are **rejected** at creation, with a message naming every
violation. Levels: `privileged` (anything), `baseline` (blocks the worst), `restricted` (best practice).

## 📖 Lesson 9.4 — NetworkPolicies

By default **every pod can talk to every pod** in the cluster. NetworkPolicies are pod firewalls (they need a
CNI that supports them — kind's default `kindnet` does since kind v0.24; Calico/Cilium in real clusters).

Start with "deny all incoming traffic" in a namespace, then allow only what's needed:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}                 # all pods in the namespace
  policyTypes: ["Ingress"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: redis-from-demo-only
spec:
  podSelector:
    matchLabels:
      app: redis                  # applies to redis pods...
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: demo           # ...only demo pods may connect...
      ports:
        - port: 6379              # ...and only to 6379
```
Remember to also allow your ingress controller's namespace to reach your web pods (see solutions).

## 📖 Lesson 9.5 — Namespaces, quotas and limits

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.memory: 4Gi
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: defaults
  namespace: dev
spec:
  limits:
    - type: Container
      default:            # limits applied when a container sets none
        memory: 256Mi
      defaultRequest:     # requests applied when a container sets none
        cpu: 100m
        memory: 64Mi
```

---

## ⚠️ Common mistakes
- Guessing instead of reading `describe` events and `logs --previous`
- Giving CI/apps `cluster-admin` "to make it work"
- Containers as root; `privileged: true` without a very good reason
- A default-deny NetworkPolicy that also blocks DNS or the ingress controller
- Forgetting that NetworkPolicies do nothing if the CNI doesn't support them

---

## 🧪 Labs
Manifests and scripts in [`solutions/`](solutions/).

### Lab 1 ⭐⭐⭐ — Five broken apps
`kubectl apply -f broken-scenarios.yaml` creates namespace `broken` with five broken apps. Run
`diagnose.sh broken` and use the method above to find and **fix** each one. Write down the symptom, the
evidence and the fix. (Hints at the bottom of the YAML file — try without them first!)

### Lab 2 ⭐⭐ — Least-privilege ServiceAccount
Apply `rbac.yaml`. Prove with `kubectl auth can-i` what `viewer` can and can't do. Then run a pod using that
ServiceAccount with `kubectl` inside it (the `alpine/k8s:1.31.2` image) and show `get pods` works but `delete` is forbidden.

### Lab 3 ⭐⭐ — Restricted namespace
Create namespace `secure` with `enforce=restricted`. Try to create a plain nginx pod (rejected — read the
message), then deploy `secure-deployment.yaml` (accepted).

### Lab 4 ⭐⭐⭐ — Network lockdown
In a namespace with demo-app and Redis, apply `network-policies.yaml`. Prove: demo → Redis works, a random
busybox pod → Redis is blocked, and the ingress controller → demo still works.

---

## ✅ Checkpoint
- [ ] I debug with a fixed method: get → describe (events) → logs --previous → exec → endpoints
- [ ] I can write Role/RoleBinding and test with `kubectl auth can-i`
- [ ] I can make pods pass the `restricted` Pod Security Standard
- [ ] I can write default-deny + allow NetworkPolicies without breaking DNS/ingress

👉 Next: [Module 10 — Kubernetes Capstone](../10-capstone/README.md)
