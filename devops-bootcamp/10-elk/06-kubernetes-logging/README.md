# ELK Module 06 — Logging on Kubernetes 🔴

## 🎯 Objectives
- Know where container logs live on a Kubernetes node and why a **DaemonSet** collects them
- Deploy **Fluent Bit** with RBAC, a ConfigMap, a Secret and hostPath volumes
- Enrich logs with Kubernetes metadata (namespace, pod, labels) and merge JSON app logs
- Ship to Elasticsearch with a write-only **API key** into a **data stream**
- Know the alternatives: Filebeat DaemonSet, Elastic Agent, the ECK operator, Loki

## 🧠 Why DevOps engineers care
In Kubernetes, pods come and go — and their logs go with them unless something ships them first. Every production
cluster runs a log DaemonSet, and when logs go missing, the DevOps engineer is the one who has to know about container
log files, the CRI format, positions databases and back-pressure.

---

## 📖 Lesson 6.1 — Where logs live

```
pod writes stdout ──► container runtime (containerd) ──► /var/log/pods/<ns>_<pod>_<uid>/<container>/0.log
                                                         /var/log/containers/<pod>_<ns>_<container>-<id>.log  (symlinks)
kubectl logs  ◄── the kubelet reads the same files (and only keeps a little: they're rotated)
```
Each line is in **CRI format**: `2026-10-03T08:04:00.000Z stderr P partial line…` — timestamp, stream, `P`(artial) or
`F`(ull), then the text. Long lines are split into several `P` lines that must be joined back together.

## 📖 Lesson 6.2 — Fluent Bit as a DaemonSet

[`fluent-bit-daemonset.yaml`](solutions/fluent-bit-daemonset.yaml): one pod per node (tolerating every taint), a
ServiceAccount with **read-only** access to pods and namespaces, `/var/log` mounted read-only, a hostPath for the
positions database, health probes on port 2020, and the Elasticsearch API key from a Secret.

[`fluent-bit.yaml`](solutions/fluent-bit.yaml) (Fluent Bit's YAML config format):
```yaml
pipeline:
  inputs:
    - name: tail
      path: /var/log/containers/*.log
      multiline.parser: cri, docker      # unwrap the runtime format, join P(artial) lines
      db: /var/fluent-bit/state/tail.db  # positions survive restarts
      read_from_head: false              # first start: skip old lines (no flood); then never miss one
  filters:
    - name: kubernetes                   # + namespace, pod, container, labels
      merge_log: on                      # demo-app's JSON → real fields
      k8s-logging.exclude: on            # pods can opt out: annotation fluentbit.io/exclude: "true"
  outputs:
    - name: es
      http_api_key: ${ES_API_KEY}        # create_doc-only key (Module 05)
      index: logs-k8s-default            # data stream → write_operation: create
      write_operation: create
```
```bash
./validate.sh                            # kubeconform + fluent-bit --dry-run (no cluster needed)
./deploy.sh <api-key>                    # into your kind cluster
kubectl -n logging logs ds/fluent-bit    # the shipper's own logs: errors connecting? auth? mapping?
```

## 📖 Lesson 6.3 — Getting Elasticsearch to the cluster

Simplest for the lab: run the Module 05 Elasticsearch on your laptop and point `ES_HOST` at your machine's IP (kind
nodes are Docker containers, so `host.docker.internal` or the Docker bridge gateway works). In production:
- **Elastic Cloud** or a managed **OpenSearch** service, reached over TLS
- **ECK** (Elastic Cloud on Kubernetes) — an operator that runs Elasticsearch and Kibana as custom resources:
  `kind: Elasticsearch` with `nodeSets`, TLS and users created for you

## 📖 Lesson 6.4 — Choosing a shipper

| | Fluent Bit | Filebeat (DaemonSet) | Elastic Agent | Promtail/Alloy → Loki |
|--|-----------|----------------------|---------------|------------------------|
| Footprint | tiny (C) | small (Go) | larger | small |
| Destinations | anything (ES, Loki, S3, Kafka, Splunk…) | Elastic / Logstash / Kafka | Elastic | Loki |
| Typical use | vendor-neutral default | Elastic-only shops | managed fleets (Fleet UI) | Grafana stacks (cheap, label-indexed) |

## 📖 Lesson 6.5 — When logs go missing

1. Is the shipper pod on that node running? (`kubectl -n logging get pods -o wide`)
2. Its own logs: connection refused, 401/403 (API key), 400 (mapping conflict), retries?
3. Did the pod log to stdout at all? (`kubectl logs <pod>`)
4. Back-pressure: Elasticsearch slow → `mem_buf_limit` reached → input paused. Use `storage.type: filesystem`
   buffering for bursts.
5. Was the pod excluded (annotation, `exclude_path`) or deleted before the next flush?

---

## ⚠️ Common mistakes
- Shipping with the `elastic` superuser instead of a scoped API key
- No positions database (`db`) → duplicates or gaps after every restart
- Shipping the shipper's own logs in a loop
- `merge_log` on apps that log plain text with a different structure in every line → mapping conflicts
- Forgetting tolerations → no logs from tainted nodes

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `./validate.sh` needs no cluster; Labs 2–4 use your kind cluster.

### Lab 1 ⭐ — Look at the files
On a kind node (`docker exec -it <cluster>-control-plane bash`), find a demo-app pod's log under `/var/log/pods` and its
symlink in `/var/log/containers`. Identify the CRI fields in one line. Delete the pod — what happens to the file?

### Lab 2 ⭐⭐ — Deploy Fluent Bit
Validate, then deploy with an API key from Module 05. Generate traffic to demo-app and find its lines in Kibana with
`kubernetes.namespace_name : demo`. Are demo-app's JSON fields (`http.response.status_code`) searchable?

### Lab 3 ⭐⭐ — Opt-out and filtering
Annotate a noisy pod with `fluentbit.io/exclude: "true"`; add a `grep` filter that drops health-check lines
(`/health`). Prove both in Kibana.

### Lab 4 ⭐⭐⭐ — Break it
Revoke the API key, watch Fluent Bit's logs and retries, issue a new key, update the Secret, and restart the
DaemonSet. Did you lose any lines? Why (or why not)?

---

## ✅ Checkpoint
- [ ] I know where container logs live on a node and what the CRI format is
- [ ] I can deploy a log DaemonSet with RBAC, config, secrets and a positions database
- [ ] Logs arrive enriched with Kubernetes metadata in a data stream, via a write-only API key
- [ ] I can troubleshoot missing logs step by step

👉 Next: [Module 07 — ELK Capstone](../07-capstone/README.md)
