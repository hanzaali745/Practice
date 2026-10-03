# ELK Module 07 — ELK Capstone 🏆

> **CEO note:** When a customer says "my order failed at 14:02", I want an engineer to find that exact request in under a
> minute — and I want to sleep at night knowing nobody can read or delete our logs who shouldn't, that old logs expire on
> schedule, and that a spike of errors tells us before the customer does.

**Definition of Done:**
- [ ] App (JSON) and nginx (text) logs from every container arrive **parsed** into one schema (ECS)
- [ ] Logs land in **data streams** with an **ILM** policy (rollover + retention)
- [ ] Security on: no anonymous access; least-privilege users for the shipper, the alerter, Kibana and developers
- [ ] Kibana data view and dashboard imported **from Git**
- [ ] A log-based alert (error spike per service) that fires **and resolves**, routed to a receiver
- [ ] A check script: static config tests + an end-to-end test that proves all of the above
- [ ] A README with the architecture, users/roles, retention and how to investigate an incident

---

## Project 1 ⭐⭐⭐ — Centralised logging for the demo platform (full reference solution)

```
 app ×2 (JSON) ─┐                                        ┌─► logs-demoapp-capstone ─┐  ILM: rollover 1 d,
 nginx (text) ──┴─► Filebeat ─► Logstash (json / grok) ─┴─► logs-nginx-capstone ───┴─ delete after 14 d
                                  user: logstash_internal              │
                                  (append only)                        ├─► Kibana (data view + dashboard from Git)
                                                                       │     users: dev (read), elastic (admin)
                                                                       └─► log_alert.py (user: log_alerter, read)
                                                                               └─► receiver #chat: LogErrorSpike
```

| Component | Identity | Can do |
|-----------|----------|--------|
| Logstash | `logstash_internal` (role `logstash_writer`) | append to `logs-demoapp-*`, `logs-nginx-*` — nothing else |
| log_alert.py | `log_alerter` (role `logs_reader`) | read logs |
| Developers | `dev` (role `logs_reader`) | search logs, read dashboards in Kibana |
| Kibana | `kibana_system` | Kibana's own system index |
| Admin | `elastic` | everything — break-glass only |

👉 Reference: [`solutions/platform/`](solutions/platform/) — copy `.env.example` to `.env` and change the passwords.

```bash
cd ~/Practice/devops-bootcamp/10-elk/07-capstone/solutions/platform
./check.sh                  # Logstash --config.test_and_exit, filebeat test config, Kibana NDJSON
./check.sh --e2e            # full stack (≈10 min): parsing, security, ILM, dashboards, alert fires + resolves
```
Then investigate like on-call: http://localhost:5601 (log in as `dev`) → **demo — logs overview**, or Discover with
`log.level : error and service.name : nginx`. Raise the error rate and watch the alert:
```bash
ERROR_FRACTION=0.5 docker compose up -d load
docker compose logs -f log-alert receiver
```
Elasticsearch gets a 2 GB memory limit here — with 1 GB it was OOM-killed under load during testing. Size memory for
the real workload, not for an idle demo.

**Stretch goals:** add a Kibana alerting rule (Elasticsearch query, "Index" connector) next to `log_alert.py` · send the
alert to the Phase 9 Alertmanager (`POST /api/v2/alerts`) so silences and routing are shared · nightly snapshots with
an SLM policy · TLS on the HTTP layer with `elasticsearch-certutil`.

---

## Project 2 ⭐⭐ — Logs ↔ metrics
Run the Phase 9 monitoring capstone and this platform together. Add a Grafana **Elasticsearch data source** and put a
"recent errors" logs panel under the RED dashboard. During a drill, go from the metric spike to the log lines in one
click — that's what observability means in practice.

## Project 3 ⭐⭐⭐ — The same platform on Kubernetes
Install ECK (Elastic Cloud on Kubernetes) in your kind cluster, create an `Elasticsearch` and a `Kibana` resource, and
ship with the Module 06 Fluent Bit DaemonSet using an API key. Recreate the ILM policy, roles and dashboard with a
Kubernetes Job running `setup.py` and `kibana_setup.sh`.

## Project 4 ⭐⭐ — Compare with Loki
Run Grafana Loki + Promtail/Alloy for the same containers. Compare: storage used after an hour, query speed for
"all 500s on /visits", what you can and can't search. Write a one-page recommendation for a small team.

---

## 🎓 ELK phase complete!
Tick the [ELK expert checklist](../README.md#-elk-expert-checklist). Metrics, logs, pipelines, servers and containers —
the last step is running all of it in the cloud.

👉 Next phase: [Phase 11 — AWS](../../11-aws/README.md)
