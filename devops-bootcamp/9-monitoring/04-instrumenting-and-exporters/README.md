# Monitoring Module 04 — Instrumenting Apps & Exporters 🟡

## 🎯 Objectives
- Read how demo-app produces its `/metrics` (counter, histogram, gauge, info metric)
- Instrument Python code and write a **custom exporter** with `prometheus_client`
- Monitor **batch and cron jobs** with node-exporter's textfile collector
- Probe services **from the outside** with `blackbox_exporter`
- Monitor software you don't own with ready-made exporters (`redis_exporter`)

## 🧠 Why DevOps engineers care
Machine metrics tell you the server is fine; only **application** metrics tell you users are getting errors. Part
of a DevOps engineer's job is making sure every service exposes the right metrics — and filling the gaps with
exporters for databases, queues, backups and cron jobs, where most silent failures hide.

---

## 📖 Lesson 4.1 — How demo-app exposes metrics

Open [`4-docker/app/app.py`](../../4-docker/app/app.py) and find the `Metrics` class — a tiny registry written with
the standard library so you can see there's no magic:
```python
METRICS.observe("GET", url.path, self._code, seconds)     # after every request
```
| Metric | Type | Labels | Why |
|--------|------|--------|-----|
| `http_requests_total` | counter | method, path, code | **R**ate and **E**rrors |
| `http_request_duration_seconds` | histogram (buckets 5 ms … 5 s) | path | **D**uration / percentiles |
| `http_requests_in_progress` | gauge | — | saturation |
| `demo_app_build_info` | gauge, always 1 | version | which build is running where |

Notice `path` only takes **known** values; anything else becomes `other` (Module 02, cardinality).

## 📖 Lesson 4.2 — `prometheus_client` (the normal way)

```python
from prometheus_client import Counter, Histogram, Gauge, start_http_server

JOBS = Counter("jobs_processed_total", "Jobs processed.", ["queue", "result"])
LATENCY = Histogram("job_duration_seconds", "Time per job.", ["queue"], buckets=(0.1, 0.5, 1, 5, 30))
QUEUE = Gauge("queue_depth", "Jobs waiting.", ["queue"])

start_http_server(8001)                       # serves /metrics in a background thread

@LATENCY.labels("emails").time()              # decorators and context managers do the timing
def send_email(job): ...
JOBS.labels("emails", "ok").inc()
QUEUE.labels("emails").set(len(pending))
```
For values you **read** at scrape time (files, an API, a database), write a **custom collector** instead — see
[`backup_exporter.py`](solutions/backup_exporter.py): every scrape it looks at a backup folder and reports file count,
newest backup time and size.

## 📖 Lesson 4.3 — Batch jobs: the textfile collector

A cron job runs for 30 seconds at 02:00 — Prometheus will probably never scrape it. Instead, the job writes its result
to a `.prom` file and node-exporter serves it ([`nightly_job.sh`](solutions/nightly_job.sh)):
```
nightly_job_last_success 1
nightly_job_last_success_timestamp_seconds 1791504000
nightly_job_duration_seconds 12
```
```yaml
  node-exporter:
    command: ["--collector.textfile.directory=/textfile"]
```
The alert you want later: *"no successful backup in 26 hours"* —
`time() - nightly_job_last_success_timestamp_seconds > 26*3600`. (For short-lived jobs in Kubernetes, the
**Pushgateway** is the other option; the textfile collector is simpler and has no single point of failure.)

## 📖 Lesson 4.4 — Exporters for things you don't own

| Exporter | Watches | Example metric |
|----------|---------|----------------|
| node_exporter | Linux machines | `node_filesystem_avail_bytes` |
| redis_exporter | Redis | `redis_up`, `redis_connected_clients`, `redis_commands_total` |
| postgres_exporter, mysqld_exporter | databases | connections, replication lag |
| blackbox_exporter | anything, from the outside | `probe_success`, `probe_duration_seconds`, `probe_ssl_earliest_cert_expiry` |
| cAdvisor | containers | per-container CPU/memory (built into the kubelet on Kubernetes) |

Search https://prometheus.io/docs/instrumenting/exporters/ before writing your own.

## 📖 Lesson 4.5 — Blackbox probing

Internal metrics can say "fine" while users can't connect (DNS, TLS, firewall). Blackbox checks from the outside:
```yaml
  - job_name: blackbox-http
    metrics_path: /probe
    params: {module: [http_health_json]}
    static_configs: [{targets: ["http://app:8000/health"]}]
    relabel_configs:
      - {source_labels: [__address__], target_label: __param_target}   # what to probe
      - {source_labels: [__param_target], target_label: instance}
      - {target_label: __address__, replacement: "blackbox:9115"}      # who probes it
```
Stop Redis and watch `probe_success{job="blackbox-tcp"}` drop to 0, `redis_up` drop to 0, and `/visits` start
returning 503 — three views of the same outage.

---

## ⚠️ Common mistakes
- Labels with unbounded values (user IDs, full URLs) — cardinality explosion
- Metric names without units or the `_total` suffix for counters (`request_time` → `request_duration_seconds`)
- Only "it's up" checks — no error, latency or business metrics
- Cron jobs with no monitoring at all; finding out the backup failed when you need the backup
- Writing an exporter that already exists

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Run `./nightly_job.sh` and `python3 backup_exporter.py backups` on your laptop
(venv active), then `docker compose up -d --build`.

### Lab 1 ⭐ — Read the instrumentation
Find where demo-app records each request, which label values `path` can take, and the histogram buckets. Change the
buckets to suit an SLO of "95% of requests under 250 ms" — which boundaries matter most?

### Lab 2 ⭐⭐ — A custom exporter
Write `backup_exporter.py` with a custom collector. Scrape it from Prometheus through `host.docker.internal`. Delete
all backups — which series disappear, and why is that useful for alerting with `absent()`?

### Lab 3 ⭐⭐ — Batch job metrics
Write `nightly_job.sh` that reports last run, last success, success flag and duration through the textfile collector,
written atomically. Run it once normally and once with `FAIL=1`, and query each state.

### Lab 4 ⭐⭐⭐ — Exporters and probes
Add Redis (with demo-app using it), `redis_exporter`, and `blackbox_exporter` probing `http://app:8000/health` (body
must contain `"status": "ok"`) and `redis:6379` over TCP. Stop Redis: list every metric that tells you something broke.

---

## ✅ Checkpoint
- [ ] I can explain counters, gauges, histograms and info metrics, with good names and labels
- [ ] I can instrument Python with prometheus_client and write a custom collector
- [ ] I monitor cron/batch jobs with the textfile collector
- [ ] I use ready-made exporters and blackbox probes, and know the blackbox relabel pattern

👉 Next: [Module 05 — Grafana Dashboards as Code](../05-grafana/README.md)
