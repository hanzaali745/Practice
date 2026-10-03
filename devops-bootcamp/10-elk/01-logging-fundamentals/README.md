# ELK Module 01 — Logging Fundamentals 🟢

## 🎯 Objectives
- Explain what logs are for, and how they complement metrics and traces
- Use log levels properly and write **structured (JSON) logs** with consistent field names (ECS)
- Follow the container rule: **log to stdout**, let the platform collect it
- Correlate all lines of one request with a **request/trace id**
- Analyse JSON logs with `jq`, and stop logs from filling disks (**rotation**)

## 🧠 Why DevOps engineers care
Metrics told you *that* error rates went up at 14:02 (Phase 9). Logs tell you *which* requests failed, *why*, and for
*whom*. But logs are only useful if they're structured, consistent, kept long enough — and don't fill the disk and take
the server down themselves. Setting those standards for every team is DevOps work.

---

## 📖 Lesson 1.1 — Log levels

| Level | Use for | In production |
|-------|---------|---------------|
| `debug` | details for developers | off (turn on temporarily) |
| `info` | normal events: started, request served, job done | on |
| `warn` | unexpected but handled: retry, slow call, 4xx | on |
| `error` | a request/operation failed: 5xx, exception | on — and counted by metrics/alerts |
| `fatal`/`critical` | the process can't continue | on |

A log line should answer **what happened, to what, where, when** — and never contain passwords, tokens or
personal data you're not allowed to store.

## 📖 Lesson 1.2 — Structured logs

```
INFO  GET /error 500 0.4ms                       ← text: easy to read, hard to search
```
```json
{"@timestamp": "2026-10-03T07:25:26.151Z", "log": {"level": "error"}, "message": "GET /error 500 0.4ms",
 "http": {"request": {"method": "GET"}, "response": {"status_code": 500}}, "url": {"path": "/error"},
 "event": {"duration": 412000}, "service": {"name": "demo-app", "version": "1.0.0"}, "host": {"name": "f2bdd310cf70"}}
```
JSON lines can be filtered and aggregated by field — *"all 500s on /visits from version 2.1.0"* — without regexes.
demo-app writes this when `LOG_FORMAT=json`. The field names follow the **Elastic Common Schema (ECS)**, so
Elasticsearch and Kibana (and other teams' logs) understand them without extra mapping.

## 📖 Lesson 1.3 — Where logs go

| Platform | App does | Platform collects with |
|----------|----------|------------------------|
| Docker | write to **stdout/stderr** | logging driver (`json-file` → `docker logs`) |
| Kubernetes | write to stdout/stderr | kubelet files in `/var/log/containers/` → a DaemonSet shipper (Module 06) |
| systemd (Phase 7) | write to stdout | journald → `journalctl -u demo-app@8001 -o json` |
| Classic VM app | write to a file | logrotate + Filebeat |

Never write log files inside a container — they vanish with it, and nothing rotates them.

## 📖 Lesson 1.4 — Correlation ids

One user click can produce 20 log lines across 4 services. Give each request an id and put it on **every** line
(and pass it to downstream services in a header like `traceparent`). Then one search shows the whole story.
[`structured_logging.py`](solutions/structured_logging.py) shows the pattern with Python's `logging` module, a JSON
formatter and a `contextvars` request id:
```bash
python3 structured_logging.py | jq -c '{level: .log.level, msg: .message, trace: .trace.id, err: .error.type}'
```

## 📖 Lesson 1.5 — Reading JSON logs with jq

```bash
docker compose logs --no-log-prefix app | grep '^{' > app.jsonl
jq -r '.http.response.status_code' app.jsonl | sort | uniq -c                 # requests by status
jq -c 'select(.log.level == "error")' app.jsonl | tail -3                      # last errors
jq -r 'select(.event) | "\(.event.duration / 1e6 | floor) \(.url.path)"' app.jsonl | sort -rn | head   # slowest
```
[`analyze_logs.sh`](solutions/analyze_logs.sh) does all of this. It works for one container — for 50 containers on
10 servers you need a central place to search: that's Elasticsearch (next module).

## 📖 Lesson 1.6 — Don't let logs fill the disk

```yaml
    logging:
      driver: json-file
      options: {max-size: "10m", max-file: "3"}     # ≤ 30 MB per container
```
Set it for every container in `/etc/docker/daemon.json` ([`docker-daemon.json`](solutions/docker-daemon.json)) and
`sudo systemctl restart docker`. For apps writing files, use **logrotate**
([`logrotate/demo-app`](solutions/logrotate/demo-app)) and test it: `sudo logrotate -d /etc/logrotate.d/demo-app`.
A full disk caused by logs is one of the most common — and most avoidable — outages.

---

## ⚠️ Common mistakes
- Free-text logs with a different format in every service
- Logging secrets, tokens or full request bodies with personal data
- Everything at `info` (or `error`) — levels that mean nothing
- Log files inside containers; no rotation on VMs (the disk fills up at 3 am)
- `print()` debugging left in production code instead of a logger

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --build`, wait 30 s, `./analyze_logs.sh`.

### Lab 1 ⭐ — Text vs JSON
Run demo-app with and without `LOG_FORMAT=json` and compare the output. Write down three questions that are easy with
JSON and hard with text.

### Lab 2 ⭐⭐ — jq analysis
With the load generator running, answer with jq: requests by status code, log levels, the 5 slowest requests, the p95
latency in ms, and the last 3 errors with time, path and host.

### Lab 3 ⭐⭐ — Structured logging in Python
Write a JSON formatter for Python's `logging` with ECS-style fields, a correlation id from `contextvars`, and
exception details for `log.exception()`. Make one request succeed and one fail; find all lines of the failing one by
its id.

### Lab 4 ⭐⭐ — Rotation
Configure Docker's `json-file` limits for the compose services and check them with
`docker inspect <container> --format '{{json .HostConfig.LogConfig}}'`. Write a logrotate config for
`/var/log/demo-app/*.log` and validate it with `logrotate -d`.

---

## ✅ Checkpoint
- [ ] I use log levels consistently and keep secrets out of logs
- [ ] I write structured JSON logs with ECS field names and a correlation id
- [ ] I know where logs go on Docker, Kubernetes, systemd and VMs
- [ ] I can analyse JSON logs with jq and prevent logs from filling disks

👉 Next: [Module 02 — Elasticsearch](../02-elasticsearch/README.md)
