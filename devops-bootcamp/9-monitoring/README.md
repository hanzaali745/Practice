# 📈 Phase 9: Monitoring (Prometheus & Grafana)

> **Before you start:** finish Phase 8 and run the [Part 3 setup](../00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md).
> **It's free and local:** every module is a Docker Compose stack on your laptop. demo-app
> ([`4-docker/app`](../4-docker/app/README.md)) now exposes `/metrics`, so you monitor the same service you've been
> building since Phase 4. Module 07 uses your kind cluster from Phase 5.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Observability & Your First Stack](01-observability-and-first-stack/README.md) | 🟢 | metrics/logs/traces, RED/USE, SLOs, Prometheus + node-exporter |
| 02 | [Prometheus in Depth](02-prometheus-in-depth/README.md) | 🟢 | scrape config, service discovery, relabeling, reloads, cardinality |
| 03 | [PromQL](03-promql/README.md) | 🟡 | rates, aggregation, error ratios, percentiles, recording rules + tests |
| 04 | [Instrumenting Apps & Exporters](04-instrumenting-and-exporters/README.md) | 🟡 | prometheus_client, custom collectors, cron jobs, blackbox, redis_exporter |
| 05 | [Grafana Dashboards as Code](05-grafana/README.md) | 🟡 | provisioning, panels, variables, dashboards in Git + tests |
| 06 | [Alerting & SLOs](06-alerting-and-slos/README.md) | 🔴 | alert rules + tests, Alertmanager routing/inhibition/silences, burn rates |
| 07 | [Monitoring Kubernetes](07-kubernetes-monitoring/README.md) | 🔴 | kube-prometheus-stack, ServiceMonitor, PrometheusRule, on-call queries |
| 08 | [Monitoring Capstone](08-capstone/README.md) | 🏆 | a tested observability platform with SLOs, runbooks and a chaos test |

## Cheat sheet

```promql
rate(http_requests_total[5m])                                         # per-second rate of a counter
sum by (code) (rate(http_requests_total[5m]))                         # aggregate (rate FIRST, then sum)
sum(rate(x_total{code=~"5.."}[5m])) / sum(rate(x_total[5m]))          # error ratio
histogram_quantile(0.95, sum by (le) (rate(x_duration_seconds_bucket[5m])))   # p95
increase(x_total[1h])   topk(5, ...)   absent(up{job="x"})   x offset 1d   predict_linear(x[6h], 4*3600)
```
```bash
promtool check config prometheus.yml   promtool check rules rules/*.yml   promtool test rules tests/*.yml
amtool check-config alertmanager.yml   amtool config routes test severity=critical   amtool silence add alertname=X --duration=1h
curl -X POST localhost:9090/-/reload   curl -G localhost:9090/api/v1/query --data-urlencode 'query=up'
```

## 🏅 Monitoring expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain metrics vs logs vs traces, golden signals, RED, USE, SLI, SLO and error budgets
- [ ] Configure Prometheus with service discovery, relabeling, retention — and keep cardinality under control
- [ ] Write PromQL for rates, ratios, percentiles, comparisons and predictions; record and unit-test rules
- [ ] Instrument an app, write a custom exporter, monitor cron jobs, and probe services from outside
- [ ] Build clear Grafana dashboards, provision them from Git, and test that every panel has data
- [ ] Write actionable, tested alerts with runbooks; route, group, inhibit and silence them in Alertmanager
- [ ] Alert on SLOs with multi-window burn rates
- [ ] Run and use kube-prometheus-stack with ServiceMonitors and PrometheusRules
- [ ] Prove the alert path end to end with a chaos drill

👉 Start: [Module 01 — Observability & Your First Stack](01-observability-and-first-stack/README.md)
