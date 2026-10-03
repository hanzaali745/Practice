# Monitoring Module 06 — Alerting & SLOs 🔴

## 🎯 Objectives
- Write **alerting rules** with `for`, severity labels, summaries and runbook links
- **Unit-test** alerts with `promtool test rules`
- Route notifications with **Alertmanager**: grouping, routes, receivers, repeat intervals
- Reduce noise with **inhibition** and **silences**
- Alert on **SLOs** with multi-window **burn rates** instead of raw thresholds
- Prove the whole chain works with a chaos test

## 🧠 Why DevOps engineers care
Bad alerting is worse than none: too many alerts and people ignore them (alert fatigue); too few and customers find
the outage first. Good alerts are **actionable** (someone must do something), **urgent** when they page, and link to a
runbook. Being able to design that — and to reason in SLOs and error budgets — is a core SRE skill.

---

## 📖 Lesson 6.1 — Alerting rules

```yaml
groups:
  - name: demo-app
    rules:
      - alert: DemoAppDown
        expr: up{job="demo-app"} == 0
        for: 1m                                  # pending → firing only if still true after 1 min
        labels:
          severity: critical                     # used for routing
        annotations:
          summary: "demo-app instance {{ $labels.instance }} is down"
          runbook_url: "https://github.com/you/runbooks/blob/main/demo-app.md#demoappdown"
```
An alert is **inactive → pending → firing**. Without `for`, a single failed scrape pages someone at 3 am. Use
`$labels`, `$value` and functions like `humanizePercentage` to make messages readable. Alert on **symptoms users feel**
(errors, latency, down) more than on causes (CPU 80%).

## 📖 Lesson 6.2 — Test your alerts

```yaml
tests:
  - interval: 15s
    input_series:
      - series: 'up{job="demo-app", instance="app-1"}'
        values: '1 1 1 0 0 0 0 0 0'              # goes down at 45 s
    alert_rule_test:
      - eval_time: 75s                           # down 30 s → not yet
        alertname: DemoAppDown
        exp_alerts: []
      - eval_time: 2m                            # down 75 s → firing
        alertname: DemoAppDown
        exp_alerts:
          - exp_labels: {severity: critical, job: demo-app, instance: app-1}
```
`./test_rules.sh` checks every rule file and runs every test — put it in CI (Phase 8) next to your app tests.

## 📖 Lesson 6.3 — Alertmanager: from alert to notification

```
Prometheus ──alerts──► Alertmanager ──group──► route by labels ──► receivers (Slack, PagerDuty, email, webhook)
                           │ inhibit: DemoAppDown mutes HighErrorRate for the same job
                           └ silence: "we know, we're on it" for 1 h
```
```yaml
route:
  receiver: chat
  group_by: [alertname, job]                 # 20 instances down = ONE notification
  group_wait: 30s
  repeat_interval: 4h
  routes:
    - matchers: [severity="critical"]
      receiver: pager
      continue: true                         # also post critical alerts to chat
    - matchers: [severity=~"warning|critical"]
      receiver: chat
inhibit_rules:
  - source_matchers: [alertname="DemoAppDown"]
    target_matchers: [alertname=~"DemoAppHighErrorRate|DemoAppHighLatency"]
    equal: [job]
```
Test routing without sending anything: `./check_alertmanager.sh` (`amtool check-config` + `amtool config routes test`).
In the lab, [`alert_receiver.py`](solutions/alert_receiver.py) plays the role of Slack and PagerDuty — swap the
`webhook_configs` for `slack_configs` (with a webhook URL kept as a secret) in real life.

## 📖 Lesson 6.4 — Silences

```bash
amtool silence add alertname=DemoAppHighErrorRate --duration=1h --comment="deploying fix, ticket OPS-123"
amtool silence query
amtool silence expire <id>
```
Use silences for known work (maintenance, an incident you're already handling) — always with a comment and an end.

## 📖 Lesson 6.5 — SLO-based alerting with burn rates

"Error ratio > 5%" pages for short blips and misses slow leaks. Instead, alert on how fast you're spending the error
budget. For an SLO of **99.5%** (budget 0.5%):

| Alert | Condition | Means | Action |
|-------|-----------|-------|--------|
| **Fast burn** | error ratio > 14.4 × 0.5% over **1 h AND 5 min** | 2% of the month's budget gone in an hour | page |
| **Slow burn** | error ratio > 6 × 0.5% over **6 h AND 30 min** | 5% of the budget gone in 6 hours | ticket |

The long window proves it's real; the short window makes the alert stop quickly once it's fixed. See
[`rules/slo.yml`](solutions/rules/slo.yml) and its tests in [`tests/slo_test.yml`](solutions/tests/slo_test.yml).
(On a freshly started stack the 1-hour window only holds a few minutes of data, so the fast-burn alert fires
sooner than it would in production — you'll see that in the chaos test.)

## 📖 Lesson 6.6 — Prove it end to end

[`chaos.sh`](solutions/chaos.sh) starts the stack and then: stops Redis → waits for `RedisDown` → checks the pager and
chat receivers got it; raises errors to 30% → `DemoAppHighErrorRate`; silences it; fixes everything → checks the
**resolved** notification. Run a drill like this whenever you change alerting.

---

## ⚠️ Common mistakes
- No `for:` → flapping alerts; `for: 1h` → you find out an hour late
- Alerts nobody can act on ("CPU 70%") — delete them or make them dashboard panels
- No runbook link; summaries without the instance or the value
- Every alert pages; warnings and critical alerts treated the same
- Never testing the notification path — the Slack webhook expired months ago

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `./test_rules.sh`, `./check_alertmanager.sh`, then `./chaos.sh` (~10 minutes).

### Lab 1 ⭐ — First alerts
Write `DemoAppDown`, `DemoAppHighErrorRate` (> 5% for 2 min, using the recording rule) and `RedisDown`, with severity,
summary and runbook. Load them and watch **Alerts** in the Prometheus UI move through pending → firing.

### Lab 2 ⭐⭐ — Unit tests
Write promtool tests: `DemoAppDown` must **not** fire after 30 s down but **must** after 75 s; the error-rate alert must
fire for 10% errors and not for 1%. Break an alert's `for:` and watch a test fail.

### Lab 3 ⭐⭐ — Alertmanager
Route critical → `pager` and chat, warning → chat; group by `alertname` and `job`; inhibit error/latency alerts while
`DemoAppDown` fires. Prove routing with `amtool config routes test`, then watch real notifications in
`docker compose logs -f receiver`.

### Lab 4 ⭐⭐⭐ — SLOs and burn rates
Define a 99.5% availability SLO for demo-app. Write recording rules for the 5 m / 30 m / 1 h / 6 h error ratios and the
remaining 30-day budget, plus fast- and slow-burn alerts with tests. Then run `chaos.sh` and explain every
notification it prints.

---

## ✅ Checkpoint
- [ ] My alerts have `for`, severity, readable annotations and runbook links
- [ ] I unit-test alert rules with promtool
- [ ] I can route, group, inhibit and silence with Alertmanager, and test routing with amtool
- [ ] I can define an SLO, its error budget, and burn-rate alerts
- [ ] I've proved the alert path end to end with a chaos test

👉 Next: [Module 07 — Monitoring Kubernetes](../07-kubernetes-monitoring/README.md)
