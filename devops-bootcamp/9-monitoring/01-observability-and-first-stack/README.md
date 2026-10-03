# Monitoring Module 01 — Observability & Your First Stack 🟢

## 🎯 Objectives
- Explain the three pillars of observability: **metrics, logs, traces**
- Use the **golden signals**, **RED** and **USE** to decide *what* to measure
- Understand SLIs, SLOs and error budgets
- Run **Prometheus** + **node-exporter** + demo-app with Docker Compose
- Find targets, read raw `/metrics`, and run your first queries in the UI and the API

## 🧠 Why DevOps engineers care
You can't fix what you can't see. Monitoring tells you a service is down **before** customers tweet about it,
shows whether a deploy made things slower, and gives you the numbers to plan capacity. "Add monitoring and
alerting" is part of almost every DevOps ticket, and being on call without good dashboards is miserable.

---

## 📖 Lesson 1.1 — Metrics, logs and traces

| Pillar | What | Answers | Tools in this course |
|--------|------|---------|----------------------|
| **Metrics** | numbers over time (requests/s, CPU %, queue length) | *Is something wrong? How much? Since when?* | Prometheus, Grafana (Phase 9) |
| **Logs** | timestamped events with details | *What exactly happened to this request?* | Elasticsearch, Logstash, Kibana (Phase 10) |
| **Traces** | the path of one request through many services | *Where did the time go?* | OpenTelemetry, Jaeger/Tempo (mentioned) |

Metrics are cheap and fast to query, so they power dashboards and alerts. Logs and traces are for digging in
once a metric told you where to look.

## 📖 Lesson 1.2 — What to measure

**The four golden signals** (Google SRE book): **latency**, **traffic**, **errors**, **saturation**.

| Method | For | Measure |
|--------|-----|---------|
| **RED** | services (demo-app, APIs) | **R**ate (requests/s), **E**rrors (failed requests/s), **D**uration (latency distribution) |
| **USE** | resources (CPU, disk, memory, network) | **U**tilisation, **S**aturation (queueing), **E**rrors |

## 📖 Lesson 1.3 — SLIs, SLOs and error budgets

- **SLI** (indicator): a measured ratio, e.g. *successful requests / all requests*
- **SLO** (objective): the target, e.g. *99.5% of requests succeed over 30 days*
- **Error budget**: what's left to "spend" — 0.5% of 30 days ≈ **3.6 hours** of failure. Budget left → ship
  features; budget gone → focus on reliability.

You'll turn these into alerts in Module 06.

## 📖 Lesson 1.4 — How Prometheus works

```
            every 15 s: GET /metrics                   PromQL
 Prometheus ─────────────────────────► targets         ◄──────── you, Grafana, alert rules
 (stores time series on disk)          demo-app:8000/metrics
                                        node-exporter:9100/metrics
```
Prometheus **pulls** ("scrapes") metrics from HTTP endpoints. Each metric is a time series identified by a name and
labels: `http_requests_total{job="demo-app", path="/", code="200"}`. Things that can't expose metrics themselves
get an **exporter** — node-exporter turns Linux kernel stats into metrics.

## 📖 Lesson 1.5 — Start your first stack

```bash
cd ~/Practice/devops-bootcamp/9-monitoring/01-observability-and-first-stack/solutions
docker compose up -d --build
docker compose ps
```
[`prometheus.yml`](solutions/prometheus.yml):
```yaml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs: [{targets: ["localhost:9090"]}]
  - job_name: node
    static_configs: [{targets: ["node-exporter:9100"]}]
  - job_name: demo-app
    static_configs: [{targets: ["app:8000"]}]
```
Open http://localhost:9090 → **Status → Target health**: three targets, all **UP**.

## 📖 Lesson 1.6 — Read raw metrics

```bash
curl -s localhost:8000/metrics
```
```
# HELP http_requests_total HTTP requests handled, by method, path and status code.
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/",code="200"} 5
http_request_duration_seconds_bucket{path="/",le="0.005"} 5
...
demo_app_build_info{version="1.0.0"} 1
```
It's just text. `# TYPE` says what kind of metric it is: **counter** (only goes up), **gauge** (up and down),
**histogram** (counts in buckets — for latency).

## 📖 Lesson 1.7 — First queries

In the UI (**Query** tab) or with [`explore.sh`](solutions/explore.sh), which calls the HTTP API:
```promql
up                                             # 1 = target scraped OK, 0 = down
http_requests_total                            # every series of that metric
sum by (path, code) (http_requests_total)      # totals per path and status
node_memory_MemAvailable_bytes / 1024^3        # free memory in GiB
```
Click **Graph** to see a series over time. Generate traffic and watch it change:
```bash
for i in $(seq 200); do curl -s localhost:8000/ > /dev/null; curl -s localhost:8000/error > /dev/null; done
```

---

## ⚠️ Common mistakes
- Monitoring only the machine (CPU, RAM) and not the service (errors, latency) users actually feel
- Treating a counter's raw value as meaningful — it's the **rate** that matters (Module 03)
- Exposing Prometheus or exporters on public interfaces (bind to `127.0.0.1` in labs, use auth in real setups)
- Too-short retention for the questions you'll ask ("what was latency last month?")

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --build`, then `./explore.sh`.

### Lab 1 ⭐ — Concepts
For demo-app, write down one SLI and an SLO for availability and one for latency. Calculate the monthly error budget
for 99.9% and for 99.5%. Classify 8 metrics you can think of as RED or USE.

### Lab 2 ⭐ — The stack
Start the stack, open **Target health**, and stop demo-app (`docker compose stop app`). How long until its target is
DOWN? What does `up{job="demo-app"}` return now? Start it again.

### Lab 3 ⭐⭐ — Raw metrics
`curl` the `/metrics` of demo-app, node-exporter (`docker compose exec prometheus wget -qO- node-exporter:9100/metrics`)
and Prometheus itself. Find one counter, one gauge and one histogram in each. How many time series does
node-exporter expose? (`count({job="node"})`)

### Lab 4 ⭐⭐ — Ask the API
Use `explore.sh` (or write your own with `curl --data-urlencode`) to answer: requests per path and code, free memory,
disk usage %, number of stored series. Add a question of your own.

---

## ✅ Checkpoint
- [ ] I can explain metrics vs logs vs traces, golden signals, RED and USE
- [ ] I can define an SLI, an SLO and calculate an error budget
- [ ] I can run Prometheus with exporters and check target health
- [ ] I can read the exposition format and run basic queries in the UI and API

👉 Next: [Module 02 — Prometheus in Depth](../02-prometheus-in-depth/README.md)
