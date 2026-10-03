# Kubernetes Module 01 — Concepts & Your Local Cluster 🟢

## 🎯 Objectives
- Explain what Kubernetes does and why teams use it
- Name the parts of a cluster: control plane, nodes, kubelet, etcd, scheduler
- Create a multi-node cluster on your laptop with **kind**
- Use `kubectl` to explore a cluster: nodes, namespaces, contexts, resources
- Understand the **declarative** model: desired state vs actual state

## 🧠 Why DevOps engineers care
Docker runs containers on **one** machine. Kubernetes runs them across **many** machines and keeps
them running: it restarts crashed containers, replaces failed nodes, rolls out new versions without
downtime and scales up under load. It's the standard platform at most companies — AWS EKS, Google GKE
and Azure AKS are all Kubernetes. Learning it is the biggest single step in a DevOps career.

---

## 📖 Lesson 1.1 — What Kubernetes does

You write **what you want** ("3 copies of demo-app:1.2, reachable on port 80"). Kubernetes makes it
true and **keeps** it true:

```
   YOU                          KUBERNETES (control loop, forever)
 ┌──────────────┐  apply   ┌──────────────────────────────────────────┐
 │ desired state│ ───────► │ observe actual state                      │
 │ (YAML)       │          │ compare with desired state                │
 └──────────────┘          │ act: start/stop/replace containers        │
                           │ repeat ↺                                  │
                           └──────────────────────────────────────────┘
```

This is called **declarative** configuration (vs **imperative**: "run this, then that"). Delete a
container by hand and Kubernetes just starts another — because the desired state still says 3.

## 📖 Lesson 1.2 — The parts of a cluster

```
 ┌───────────────── CONTROL PLANE ─────────────────┐
 │  kube-apiserver  ← everything talks to this      │
 │  etcd            ← the database of desired state │
 │  scheduler       ← picks a node for each pod     │
 │  controller-manager ← the control loops          │
 └──────────────────────┬──────────────────────────┘
                        │
     ┌──────────────────┼──────────────────┐
 ┌───┴────── NODE ──────┐       ┌───────── NODE ───────┐
 │ kubelet  (runs pods) │       │ kubelet              │
 │ kube-proxy (network) │       │ kube-proxy           │
 │ containerd (runtime) │       │ containerd           │
 │  [pod] [pod] [pod]   │       │  [pod] [pod]         │
 └──────────────────────┘       └──────────────────────┘
```

| Word | Meaning |
|------|---------|
| **Cluster** | control plane + nodes |
| **Node** | a machine (VM or physical) that runs your containers |
| **Pod** | the smallest unit: one (or a few tightly coupled) containers sharing an IP |
| **kubectl** | the command line you use to talk to the API server |
| **Manifest** | a YAML file describing a resource |

## 📖 Lesson 1.3 — Create your cluster with kind

**kind** runs each Kubernetes "node" as a Docker container — a real multi-node cluster on your laptop.

`kind-config.yaml` (also in [`solutions/kind-config.yaml`](solutions/kind-config.yaml)):
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: lab
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:            # lets you reach the cluster's ingress on localhost:80 / :443 (Module 04)
      - containerPort: 80
        hostPort: 80
      - containerPort: 443
        hostPort: 443
  - role: worker
  - role: worker
```

```bash
kind create cluster --config kind-config.yaml    # takes 1-2 minutes
kubectl cluster-info
kubectl get nodes
```
```
NAME                STATUS   ROLES           AGE   VERSION
lab-control-plane   Ready    control-plane   60s   v1.34.0
lab-worker          Ready    <none>          40s   v1.34.0
lab-worker2         Ready    <none>          40s   v1.34.0
```

```bash
docker ps                      # each node is a container!
kind get clusters
kind delete cluster --name lab # when you want to start fresh (it's cheap — recreate any time)
```

> Something else on port 80? Change `hostPort: 80` to e.g. `8081` (and use that port in Module 04).

## 📖 Lesson 1.4 — kubectl basics

The pattern is always **`kubectl <verb> <resource> [name] [flags]`**:

```bash
kubectl get nodes                     # list
kubectl get nodes -o wide             # more columns (IPs, OS, runtime)
kubectl describe node lab-worker      # everything about one object (+ recent events)
kubectl get pods -A                   # pods in ALL namespaces — the system components!
kubectl get all -n kube-system        # common resources in one namespace
kubectl api-resources                 # every resource type the cluster knows
kubectl explain pod.spec.containers   # built-in documentation for any field ⭐
kubectl get node lab-worker -o yaml   # the full object as YAML
```

Short names save typing: `po` pods, `deploy` deployments, `svc` services, `ns` namespaces,
`cm` configmaps, `no` nodes. With the alias from setup: `k get po`.

## 📖 Lesson 1.5 — Namespaces

Namespaces split one cluster into separate areas (per team, per app, per environment):

```bash
kubectl get namespaces
kubectl create namespace dev
kubectl get pods -n dev                              # -n picks a namespace
kubectl config set-context --current --namespace=dev # make "dev" the default for this context
kubectl config view --minify | grep namespace
kubectl config set-context --current --namespace=default
```

## 📖 Lesson 1.6 — Contexts: which cluster am I talking to?

`~/.kube/config` can hold many clusters (your kind cluster, staging EKS, production GKE...). A
**context** = cluster + user + default namespace.

```bash
kubectl config get-contexts           # * marks the current one
kubectl config current-context        # kind-lab
kubectl config use-context kind-lab
```

> ⚠️ The #1 Kubernetes accident is running a command against **production** when you thought you were
> on dev. **Always check `kubectl config current-context` before anything destructive.** Many engineers
> show the context in their shell prompt.

## 📖 Lesson 1.7 — Your first object (preview)

```bash
kubectl create deployment hello --image=nginx:1.27-alpine --replicas=2   # imperative, quick
kubectl get deployments,pods -o wide          # pods spread across worker nodes
kubectl delete pod <one-of-the-pod-names>     # "break" it...
kubectl get pods                              # ...a replacement appears within seconds 🎉
kubectl delete deployment hello
```
From Module 02 on, we write **YAML manifests** instead (declarative, reviewable, stored in Git).

---

## ⚠️ Common mistakes
- Forgetting `-n <namespace>` → "No resources found" (they're in another namespace)
- Running commands against the wrong context
- Thinking a pod is a container (a pod *wraps* one or more containers)
- Docker not running → `kind create cluster` fails; check `docker ps` first

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Build the lab cluster
Create the 3-node `lab` cluster from `kind-config.yaml`. Show the nodes with `-o wide`, find the node
containers with `docker ps`, and list every pod in `kube-system`. Which component runs on which node?

### Lab 2 ⭐ — Explore with explain
Use `kubectl explain` to answer: What fields does `pod.spec.containers.resources` have? What is
`deployment.spec.strategy.rollingUpdate.maxSurge`? (Write the answers down in your own words.)

### Lab 3 ⭐⭐ — Self-healing demo
Create a 3-replica nginx deployment, delete **all** its pods with one command (`-l app=hello`), and
watch them come back with `kubectl get pods -w`. Then `docker stop lab-worker2` (a "node failure"):
what happens to the node status and, after ~5 minutes, the pods? Start it again afterwards.

### Lab 4 ⭐⭐ — Cluster report script
`cluster_report.sh` prints the current context (and refuses to run unless it starts with `kind-`),
node names/roles/versions, pods per namespace (count), and any pods not in `Running`/`Completed` state.

---

## ✅ Checkpoint
- [ ] I can explain desired vs actual state and what the control plane does
- [ ] I can create/delete a kind cluster and list nodes, pods and namespaces
- [ ] I use `kubectl explain` and `describe` to learn and debug
- [ ] I always check my current context before destructive commands

👉 Next: [Module 02 — Pods & kubectl](../02-pods-and-kubectl/README.md)
