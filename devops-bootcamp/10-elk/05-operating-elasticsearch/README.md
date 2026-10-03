# ELK Module 05 — Operating Elasticsearch 🔴

## 🎯 Objectives
- Turn **security** on: built-in users, passwords, Kibana's service user, TLS (and why the lab skips it)
- Create **roles**, **users** and **API keys** with least privilege
- Store logs in **data streams** and manage retention with **index lifecycle management (ILM)**
- Take **snapshots** and **restore** after a disaster
- Read cluster health, shard allocation and heap usage; size a cluster sensibly

## 🧠 Why DevOps engineers care
An unsecured Elasticsearch on the internet gets found and wiped (or ransomed) within hours — it has happened to
thousands of companies. Logs also contain sensitive data, grow forever unless something deletes them, and are only as
safe as your last tested restore. Running Elasticsearch is mostly about security, retention and backups.

---

## 📖 Lesson 5.1 — Security on

```yaml
    environment:
      xpack.security.enabled: "true"
      ELASTIC_PASSWORD: ${ELASTIC_PASSWORD:-bootcamp-elastic}    # the built-in superuser
```
```bash
cp .env.example .env                       # and change the passwords
docker compose up -d --wait
curl -s -o /dev/null -w '%{http_code}\n' localhost:9200/            # 401
curl -s -u "elastic:$ELASTIC_PASSWORD" localhost:9200/              # works
```
| Built-in user | Use for |
|---------------|---------|
| `elastic` | break-glass admin only — never in apps or Kibana config |
| `kibana_system` | Kibana's own connection to Elasticsearch (the `setup` service sets its password) |
| your users / API keys | people and programs, each with its own role |

## 📖 Lesson 5.2 — TLS

The lab uses plain HTTP on `127.0.0.1`. Anywhere else, enable TLS: `xpack.security.http.ssl.enabled: true` with a
certificate (`elasticsearch-certutil`, your company CA, or cert-manager on Kubernetes), and transport TLS between nodes
(required as soon as you have more than one node). Clients then use `https://` and trust the CA.

## 📖 Lesson 5.3 — Roles, users and API keys

```json
PUT /_security/role/logs_reader
{"indices": [{"names": ["logs-demoapp-*", "demo-logs-*"], "privileges": ["read", "view_index_metadata"]}],
 "applications": [{"application": "kibana-.kibana",
                   "privileges": ["feature_discover.read", "feature_dashboard.read"], "resources": ["*"]}]}

PUT /_security/user/dev   {"password": "...", "roles": ["logs_reader"]}

POST /_security/api_key   {"name": "filebeat-web-1", "expiration": "30d",
  "role_descriptors": {"shipper": {"indices": [{"names": ["logs-demoapp-*"], "privileges": ["create_doc", "auto_configure"]}]}}}
```
Developers can **read** logs but not change or delete them; a log shipper can only **append** and can't read anything
(so a stolen shipper key leaks nothing). Use one API key per host or service, with an expiry, and revoke it with
`DELETE /_security/api_key`.

## 📖 Lesson 5.4 — Data streams and ILM

A **data stream** is an append-only name (`logs-demoapp-default`) backed by hidden indices that **roll over**:
```
logs-demoapp-default ─► .ds-logs-demoapp-default-2026.10.03-000001   (yesterday, read-only)
                     └► .ds-logs-demoapp-default-2026.10.03-000002   (today, written to)
```
**ILM** decides when to roll over and when to delete:
```json
PUT /_ilm/policy/demo-logs-7d
{"policy": {"phases": {
   "hot":    {"actions": {"rollover": {"max_age": "1d", "max_primary_shard_size": "10gb"}}},
   "delete": {"min_age": "7d", "actions": {"delete": {}}}}}}
```
Attach it in the index template (`"index.lifecycle.name": "demo-logs-7d"`, `"data_stream": {}`). Bigger setups add
`warm`/`cold` phases (cheaper nodes, fewer replicas, force-merge) before delete. Naming convention:
`logs-<dataset>-<namespace>` — note the built-in `logs-*-*` template has priority 100, so yours must be higher.
Check what ILM is doing: `GET logs-demoapp-default/_ilm/explain`.

## 📖 Lesson 5.5 — Snapshots

```json
PUT /_snapshot/lab   {"type": "fs", "settings": {"location": "/snapshots/lab"}}   # path must be in path.repo
PUT /_snapshot/lab/snap-1?wait_for_completion=true   {"indices": "logs-demoapp-*", "include_global_state": false}
POST /_snapshot/lab/snap-1/_restore                   {"indices": "logs-demoapp-*"}
```
Snapshots are incremental and consistent; copying the data folder is not a backup. In production use an S3/GCS/Azure
repository (Phase 11) and **snapshot lifecycle management** (`PUT /_slm/policy/nightly`) to take and expire them on a
schedule. A backup you've never restored is a hope, not a backup — [`ops_tour.sh`](solutions/ops_tour.sh) deletes the
data and restores it to prove it.

## 📖 Lesson 5.6 — Health and sizing

```bash
GET _cluster/health                  # green / yellow / red, unassigned shards
GET _cat/shards?v&s=state            # which shards are where (and UNASSIGNED ones)
GET _cluster/allocation/explain      # WHY a shard isn't assigned (Module 02's disk watermark story)
GET _nodes/stats/jvm                 # heap used — sustained > 85% means trouble
GET _cat/indices?v&s=store.size:desc # biggest indices
```
Rules of thumb: heap ≤ half of RAM and ≤ ~30 GB; shards of 10–50 GB; at least 3 master-eligible nodes for a real
cluster; one replica for redundancy; monitor Elasticsearch itself (the Phase 9 stack has an Elasticsearch exporter).

---

## ⚠️ Common mistakes
- Security off "just for now" on a reachable network
- Apps and Kibana connecting as `elastic`
- One shared, never-expiring API key for every shipper
- No ILM → disks fill up; or ILM deletes logs you're legally required to keep
- Snapshots stored on the same disk as the data, and never test-restored
- Hundreds of tiny daily indices → too many shards → memory pressure

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --wait`, then `./ops_tour.sh` runs and checks every step.

### Lab 1 ⭐ — Secure it
Start the cluster with security on and passwords from `.env`. Prove anonymous requests get 401, then log in to
Kibana as `elastic`. Why does Kibana itself connect as `kibana_system`?

### Lab 2 ⭐⭐ — Least privilege
Create a `logs_reader` role and a `dev` user; prove dev can search but not write or delete. Create a shipper API key
that can only append, prove it can't read, then revoke it.

### Lab 3 ⭐⭐⭐ — Retention
Create the `demo-logs-7d` ILM policy and a data stream template for `logs-demoapp-*`. Write to it, roll it over by
hand, and read `_ilm/explain`. What would you change for logs you must keep for a year?

### Lab 4 ⭐⭐⭐ — Disaster drill
Register a snapshot repository, snapshot the data stream, delete it, restore it, and compare document counts. Then
create an SLM policy that snapshots nightly and keeps 14 snapshots.

---

## ✅ Checkpoint
- [ ] Security is on, with separate service users, people and API keys — none of them `elastic`
- [ ] I can write roles and API keys with least privilege
- [ ] I use data streams with ILM for rollover and retention
- [ ] I take snapshots, restore them, and automate them with SLM
- [ ] I can read cluster health, find unassigned shards and know the sizing rules of thumb

👉 Next: [Module 06 — Logging on Kubernetes](../06-kubernetes-logging/README.md)
