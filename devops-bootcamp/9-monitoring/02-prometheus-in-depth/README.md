# Monitoring Module 02 — Prometheus in Depth 🟢

## 🎯 Objectives
- Configure scrape jobs, intervals, timeouts and external labels
- Find targets automatically with **service discovery** (DNS and files; Kubernetes in Module 07)
- Reshape labels with **relabel_configs** (before scraping) and **metric_relabel_configs** (after)
- Validate config with **promtool** and **reload** without restarting
- Size storage with **retention** settings, and understand **cardinality**

## 🧠 Why DevOps engineers care
In real systems targets come and go all day — containers scale, servers get replaced. Hard-coding IPs doesn't work.
Service discovery and relabeling are how one Prometheus keeps track of thousands of targets, and cardinality control
is what stops it from running out of memory. These are the settings you'll touch most often in production.

---

## 📖 Lesson 2.1 — Anatomy of `prometheus.yml`

```yaml
global:
  scrape_interval: 15s                # default for every job
  scrape_timeout: 10s                 # must be < interval
  external_labels: {cluster: lab, env: dev}    # identify this Prometheus to the outside world
rule_files: ["rules/*.yml"]           # Modules 03 and 06
alerting: {alertmanagers: [...]}      # Module 06
scrape_configs:
  - job_name: demo-app                # becomes the "job" label
    metrics_path: /metrics            # default
    scheme: http
    scrape_interval: 30s              # override per job
    static_configs | dns_sd_configs | file_sd_configs | kubernetes_sd_configs | ec2_sd_configs ...
```
Every scraped series automatically gets `job` and `instance` labels, and every target gets an `up` series.

## 📖 Lesson 2.2 — Service discovery

```yaml
  - job_name: demo-app
    dns_sd_configs:                   # every IP behind the DNS name "app"
      - names: ["app"]
        type: A
        port: 8000
```
`docker compose up -d --scale app=5` → five targets within 15 s, no config change. In the cloud the same idea is
`ec2_sd_configs` (by tag) or `kubernetes_sd_configs` (by pod/service).

**File SD** — your own scripts or tools write JSON/YAML files, Prometheus watches them:
```yaml
    file_sd_configs:
      - files: ["/etc/prometheus/targets/*.json"]
```
```json
[{"targets": ["node-exporter:9100"], "labels": {"role": "host", "team": "platform"}}]
```
[`add_target.sh`](solutions/add_target.sh) writes such a file safely (write to a temp file, then rename).

## 📖 Lesson 2.3 — Relabeling

Labels starting with `__` are hidden "meta" labels from discovery (`__address__`, `__meta_dns_name`,
`__meta_kubernetes_pod_label_app`...). They're dropped after relabeling unless you copy them.

```yaml
    relabel_configs:                       # on TARGETS, before the scrape
      - source_labels: [__address__]
        regex: "([^:]+):.*"
        target_label: ip                   # new label from part of the address
      - target_label: service
        replacement: demo-app              # a constant label
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        regex: "true"
        action: keep                       # only scrape matching targets (keep / drop)

    metric_relabel_configs:                # on SERIES, after the scrape
      - source_labels: [__name__]
        regex: "node_scrape_collector_.*"
        action: drop                       # don't store what you'll never query
```
Debug relabeling in the UI: **Status → Service discovery** shows labels before and after.

## 📖 Lesson 2.4 — Check, reload, retain

```bash
./check_config.sh       # promtool check config — like nginx -t
./reload.sh             # check + POST /-/reload (needs --web.enable-lifecycle) — no restart, no lost data
```
Storage flags: `--storage.tsdb.retention.time=15d` and/or `--storage.tsdb.retention.size=50GB` (oldest data goes
first). Prometheus is built for weeks, not years — long-term storage uses **remote_write** to Thanos, Mimir or
a managed service.

## 📖 Lesson 2.5 — Cardinality: the #1 way to break Prometheus

Every unique combination of labels is a separate series held in memory:
```
http_requests_total{path="/", code="200"}            ← fine: a handful of paths × codes
http_requests_total{path="/user/48151623", ...}      ← one series per user → millions → out of memory
```
Never use unbounded values (user IDs, emails, full URLs, request IDs) as label values. demo-app maps unknown paths to
`path="other"` for exactly this reason. Check: `prometheus_tsdb_head_series`, and
`topk(10, count by (__name__) ({__name__=~".+"}))` for the biggest metrics.

---

## ⚠️ Common mistakes
- Hard-coded target IPs that go stale
- `scrape_timeout` ≥ `scrape_interval`
- Relabel rules that silently drop every target (check **Service discovery** in the UI)
- High-cardinality labels; storing metrics nobody queries
- Restarting Prometheus to change config (loses in-flight data) instead of reloading

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --build`.

### Lab 1 ⭐ — Config tour
Add `external_labels`, a per-job `scrape_interval`, and retention by time **and** size. Validate with
`check_config.sh`. Break the YAML on purpose and read promtool's error.

### Lab 2 ⭐⭐ — DNS discovery
Run demo-app with 3 replicas and discover them with `dns_sd_configs`. Scale to 5 and back to 2 and watch
**Target health**. Add an `ip` label from `__address__` and a constant `service` label.

### Lab 3 ⭐⭐ — File discovery
Move node-exporter into `targets/node.json` with `role` and `team` labels. Write `add_target.sh` and add Prometheus
itself as a second file target without reloading. Why must the script write a temp file and rename it?

### Lab 4 ⭐⭐⭐ — Cardinality and reload
Drop node-exporter's `node_scrape_collector_*` series with `metric_relabel_configs`, reload with `reload.sh`, and
compare `count({job="file-targets"})` before and after. Find the five metrics with the most series.

---

## ✅ Checkpoint
- [ ] I can write scrape jobs with intervals, timeouts and external labels
- [ ] I can use DNS and file service discovery instead of hard-coded targets
- [ ] I can relabel targets and drop series, and debug it in the UI
- [ ] I validate and reload config safely, and I know what cardinality is and how to keep it low

👉 Next: [Module 03 — PromQL](../03-promql/README.md)
