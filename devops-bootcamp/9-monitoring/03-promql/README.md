# Monitoring Module 03 — PromQL 🟡

## 🎯 Objectives
- Select series with label matchers; understand instant vectors and range vectors
- Turn counters into rates with `rate`, `irate` and `increase`
- Aggregate with `sum by`, `avg`, `max`, `topk`, `count`
- Calculate error ratios and **latency percentiles** with `histogram_quantile`
- Compare with the past (`offset`) and predict the future (`predict_linear`)
- Pre-compute queries with **recording rules** and unit-test them with `promtool`

## 🧠 Why DevOps engineers care
PromQL is how you ask your systems questions — every dashboard panel and every alert is a PromQL expression. Engineers
who can write *"error ratio per service over 5 minutes"* or *"p95 latency by endpoint"* from memory debug incidents in
minutes instead of hours. It's also a standard interview topic for SRE and platform roles.

---

## 📖 Lesson 3.1 — Selecting series

```promql
http_requests_total                                   # every series with that name
http_requests_total{job="demo-app", code="500"}       # exact match
http_requests_total{code=~"5.."}                      # regex match  (!= and !~ negate)
http_requests_total{path!="/metrics"}
http_requests_total[5m]                               # RANGE vector: all samples of the last 5 minutes
```
An **instant vector** has one value per series (what you graph). A **range vector** has many values per series —
you can't graph it directly; you pass it to a function like `rate()`.

## 📖 Lesson 3.2 — Counters need `rate`

A counter only goes up (and resets to 0 when the process restarts). Its raw value is rarely useful:
```promql
rate(http_requests_total[5m])        # per-second average over 5 min — handles resets. Use this 95% of the time
irate(http_requests_total[5m])       # based on the last two samples only — spiky, for fast-moving graphs
increase(http_requests_total[1h])    # total increase over 1 h (= rate × seconds)
```
Rule of thumb: the range should be at least **4× the scrape interval**. Never `rate()` a gauge; never `sum()` a
counter *before* `rate()` — always **rate first, then sum**.

## 📖 Lesson 3.3 — Aggregation

```promql
sum(rate(http_requests_total[5m]))                       # one number: the whole service
sum by (instance) (rate(http_requests_total[5m]))        # one per instance
sum without (instance, ip) (rate(http_requests_total[5m]))
topk(3, sum by (path) (rate(http_requests_total[5m])))   # the 3 busiest paths
count(up == 1)                                           # how many targets are up
avg by (instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m]))   # CPU busy per machine (0-1)
```

## 📖 Lesson 3.4 — Ratios and percentiles (RED in PromQL)

```promql
# Error ratio
sum(rate(http_requests_total{code=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

# p95 latency — from a histogram: rate the buckets, keep "le", then ask for the quantile
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
histogram_quantile(0.95, sum by (path, le) (rate(http_request_duration_seconds_bucket[5m])))   # per path

# Average latency
sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))
```
Averages hide pain: if 95 requests take 10 ms and 5 take 2 s, the average is ~110 ms but 1 user in 20 waits 2 s.
**Use percentiles for latency.** (They're estimates from bucket boundaries — choose buckets around your SLO.)

## 📖 Lesson 3.5 — Time travel and prediction

```promql
sum(rate(http_requests_total[5m])) / sum(rate(http_requests_total[5m] offset 1d))   # today vs same time yesterday
predict_linear(node_filesystem_avail_bytes{mountpoint="/"}[6h], 4 * 3600) < 0        # disk full within 4 h?
time() - process_start_time_seconds                                                   # uptime in seconds
changes(process_start_time_seconds[1h])                                               # restarts in the last hour
absent(up{job="demo-app"})                                                            # 1 if the job vanished entirely
```

## 📖 Lesson 3.6 — Recording rules (and testing them)

Expensive queries used by many dashboards and alerts should be computed once, on a schedule:
```yaml
groups:
  - name: demo-app-red
    rules:
      - record: job:http_requests_errors:ratio_rate5m          # naming: level:metric:operations
        expr: |
          sum by (job) (rate(http_requests_total{code=~"5.."}[5m]))
          /
          sum by (job) (rate(http_requests_total[5m]))
```
Rules are code, so test them: [`tests/recording_test.yml`](solutions/tests/recording_test.yml) feeds fake series in
and checks the output — `./test_rules.sh` runs `promtool check rules` and `promtool test rules`, no Prometheus needed.

---

## ⚠️ Common mistakes
- Graphing raw counters, or `sum()` before `rate()`
- `rate(x[30s])` with a 15 s scrape interval → gaps and nonsense (use ≥ 4× the interval)
- Dropping `le` before `histogram_quantile` → no result
- Averages for latency instead of percentiles
- Dividing series with different labels → empty result (aggregate both sides the same way, or use `on()`/`ignoring()`)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --build` (demo-app ×2 + a load generator), wait 2
minutes, then `./promql_lab.sh` prints every answer.

### Lab 1 ⭐ — Selectors and rates
Write queries for: requests/s per instance, for the whole service, and per status code; requests in the last 5 minutes.
Graph the per-instance query in the UI and stop one replica — what happens to the graph?

### Lab 2 ⭐⭐ — RED
Error ratio for the service; p50, p95 and p99 latency; p95 per path; average latency. Explain why p95 for `/work` is so
different from `/`, and why the overall average is misleading.

### Lab 3 ⭐⭐ — Time and comparisons
Traffic now vs 1 minute ago; busiest path with `topk`; uptime per instance; restarts in the last hour
(`docker compose restart app` and check). Use `predict_linear` on node-exporter's filesystem metric (Module 01 stack).

### Lab 4 ⭐⭐⭐ — Recording rules with tests
Write recording rules for R, E and D per job, load them with `rule_files`, and check them in **Status → Rules**.
Write a `promtool` unit test that proves the error-ratio and p95 rules compute what you expect from known input.

---

## ✅ Checkpoint
- [ ] I can select series with matchers and know instant vs range vectors
- [ ] I always `rate` counters (then aggregate), and choose sensible ranges
- [ ] I can compute error ratios and percentile latency from histograms
- [ ] I can write recording rules and unit-test them with promtool

👉 Next: [Module 04 — Instrumenting Apps & Exporters](../04-instrumenting-and-exporters/README.md)
