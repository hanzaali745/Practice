# 🗺️ Planned additions — Phase 13 · Platform skills

Agreed on 2026-10-03: these gaps are real, but we build them **when you reach Phase 8 (CI/CD)** — by then you have the
Docker, Kubernetes and Terraform background they build on. Until then, nothing here is part of the daily plan.

**How you'll be reminded:**
- `sh today.sh` shows a reminder every day from the start of Phase 8 while anything below is still `PLANNED`.
- Claude Code reads [`../CLAUDE.md`](../CLAUDE.md) in every session in this repository and will suggest building these
  when your progress reaches Phase 8.

To start, tell Claude: **"let's add the Phase 13 platform skills"**. When an item is built, its status changes to
`DONE` (and the reminder stops when none are `PLANNED`).

---

## 1. Databases for DevOps (PostgreSQL)
Status: PLANNED
- Running PostgreSQL: config, roles and permissions, connections
- Backups that work: `pg_dump`, base backups + WAL/point-in-time recovery, **tested restores**
- Replication and failover basics; connection pooling (PgBouncer)
- Schema migrations in a CI/CD pipeline; zero-downtime (expand/contract)
- Labs in Docker with checkers, like the other phases

## 2. Secrets management
Status: PLANNED
- HashiCorp Vault: KV secrets, policies, AppRole, **dynamic database credentials**, audit log
- Cloud secret managers (AWS Secrets Manager / SSM Parameter Store) from apps and pipelines
- Kubernetes: External Secrets Operator (or Sealed Secrets)
- Rotation and leak response (builds on Phase 12, Module 03)

## 3. Distributed tracing with OpenTelemetry + the Grafana stack
Status: PLANNED
- Instrument demo-app with OpenTelemetry; run the OpenTelemetry Collector
- Traces in **Grafana Tempo** (or Jaeger), logs in **Grafana Loki**, metrics in Prometheus
- Grafana: jump from a metric spike → the trace → the logs of that request
- Sampling, cost, and what to trace

## 4. Optional — decide when we get there
Status: OPTIONAL
- Azure or GCP (if job ads near you ask for them instead of AWS)
- Packer (machine images, with Terraform)
- Message queues (RabbitMQ / Kafka / SQS) for system design
