# demo-app

The sample service used from Phase 4 onwards (Docker, Kubernetes, Terraform, Ansible, CI/CD, Monitoring, ELK, AWS).
Standard library only.

```bash
python3 app.py                         # http://localhost:8000
curl localhost:8000/ ; curl localhost:8000/health ; curl localhost:8000/visits
python3 -m pytest -q                   # tests
```

| Env var | Default | Meaning |
|---------|---------|---------|
| `PORT` | `8000` | listen port |
| `APP_VERSION` | `1.0.0` | reported version |
| `APP_MESSAGE` | `Hello from demo-app` | greeting |
| `REDIS_HOST` / `REDIS_PORT` | unset / `6379` | store `/visits` in Redis |
| `REDIS_PASSWORD` | unset | Redis password (sent with `AUTH`) — used by the Ansible track |
| `LOG_FORMAT` | `text` | `json` = one JSON object per line with Elastic Common Schema fields — used by the ELK track |

| Endpoint | What it's for |
|----------|---------------|
| `GET /` | greeting, version and hostname — see which instance answered |
| `GET /health` | health checks and probes |
| `GET /visits` | a counter, in Redis if `REDIS_HOST` is set (503 if Redis is down) |
| `GET /work?ms=200` | keeps a CPU busy for 200 ms (max 2000) — autoscaling and latency labs |
| `GET /error` | always 500 — error-rate, alerting and logging labs |
| `GET /metrics` | Prometheus metrics: `http_requests_total`, `http_request_duration_seconds`, `http_requests_in_progress`, `demo_app_build_info` |
