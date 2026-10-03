# System design — worked answers

One good answer each, in the framework's order. Yours can differ; check that you covered requirements, failure modes
and trade-offs.

---

## Design 1 — CI/CD platform for 20 microservices

**Clarify:** languages? Kubernetes already exists (yes). Compliance needs (approvals, audit)? Monorepo or many repos
(many). Who owns pipelines today (nobody — each team copies scripts)?

**Design**
- **One reusable pipeline**, many callers: a shared repo with reusable workflows / templates (lint → test → build →
  scan → sign → push → deploy). Each service's pipeline is ~10 lines calling it with parameters. Versioned (`@v3`),
  so the platform team can improve it safely. [8-cicd/06]
- **Build once, promote the same artefact:** image tagged with the commit SHA, pushed to one registry, signed (cosign),
  SBOM + provenance attached; staging and production deploy the same **digest**.
- **GitOps for deployment:** a config repo per environment (or per team) with Helm/Kustomize values; CI only opens/merges
  a PR that bumps the image digest; **Argo CD** syncs clusters. Audit = Git history; rollback = revert. [8-cicd/07]
- **Promotion:** automatic to staging after merge; production after automated checks (smoke/e2e, SLO health) and,
  where required, an approval in an environment. Progressive delivery (Argo Rollouts canary with metric analysis)
  for the riskiest services.
- **Security:** OIDC to the cloud (no keys), least-privilege tokens, pinned actions, secret scanning, branch protection
  with required checks and reviews, admission policy that only allows signed images.
- **Speed:** caching (deps, Docker layers), parallel jobs, only run what changed, ephemeral self-hosted runners in the
  cluster if hosted runners are too slow/expensive.

**Failure modes:** CI provider down → deploys pause but production keeps running (GitOps pulls); a bad shared-pipeline
release → teams pin versions, canary the pipeline on a few repos first; registry down → mirror/pull-through cache;
broken deploy → automatic rollback on failed health checks.

**Trade-offs:** GitOps adds a repo and a tool, but gives drift correction and audit. A central pipeline risks being a
bottleneck → make it extensible (hooks/inputs), treat it as a product with docs and an owner.

**Measure success** with DORA metrics: deploy frequency, lead time, change failure rate, time to restore.

---

## Design 2 — Highly available shop on AWS

**Clarify:** 2,000 req/s peak (~10× average?), 99.95% ≈ 22 min downtime/month, data size, RPO/RTO for the database
(say RPO 5 min, RTO 30 min), EU users → one region (eu-west-1) + CDN; budget → no multi-region active-active.

**Design**
- **Edge:** Route 53 → **CloudFront** (static assets and images cached at the edge, TLS via ACM, AWS WAF for common
  attacks and rate limiting).
- **Compute:** **ALB** across 3 AZs → **ECS Fargate** service (or EKS if the company runs Kubernetes) with tasks
  spread across AZs, target-tracking autoscaling on CPU/requests, min capacity sized to survive losing one AZ.
  Stateless app: sessions in **ElastiCache Redis** (Multi-AZ). [11/06, 11/08]
- **Data:** **RDS PostgreSQL Multi-AZ** (synchronous standby, automatic failover ~1–2 min), read replica for reporting,
  automated backups + PITR (RPO minutes), RDS Proxy for connection pooling. User uploads → **S3** (versioned,
  lifecycle to cheaper classes), served via CloudFront. [11/05]
- **Async work:** SQS queues + workers for emails, image resizing — absorbs spikes and decouples failures.
- **Network:** VPC with public (ALB, NAT per AZ) and private subnets (app, data); security groups chained ALB → app →
  DB; VPC endpoints for S3/ECR to cut NAT cost. [11/03]
- **Delivery & ops:** everything in Terraform; CI/CD with OIDC; CloudWatch + Prometheus/Grafana dashboards, SLO burn-rate
  alerts, centralised logs; runbooks.

**Failure modes:** an AZ fails → ALB stops routing there, autoscaling replaces capacity in other AZs, RDS fails over;
a bad deploy → circuit breaker / canary rollback; DB overload → read replicas, caching, RDS Proxy; region failure →
accepted risk at this budget, mitigated with cross-region backups (restore within hours) — say so explicitly.

**Cost levers:** Savings Plans for the baseline, Spot (Fargate Spot) for workers, CDN offload, right-sizing, NAT via
endpoints.

---

## Design 3 — Observability for 50 services

**Clarify:** 300 alerts/week but outages missed → alerts are on causes, not symptoms. Retention needs? Budget/build vs
buy? Existing tools?

**Design**
- **Standards first:** every service exposes RED metrics (`/metrics`), logs JSON with a common schema (ECS fields +
  trace id), propagates trace context (OpenTelemetry SDKs). A service template/library makes this the default.
- **Metrics:** Prometheus per cluster (kube-prometheus-stack, ServiceMonitors) → remote-write to long-term storage
  (Thanos/Mimir or a managed service) for a global view across 3 clusters. Recording rules for SLIs.
- **Logs:** Fluent Bit DaemonSet → Elasticsearch/OpenSearch (or Loki for cost) with ILM: 7 days hot, 30 warm, then
  deleted or archived to S3; per-team indices/data streams; PII filtering in the pipeline. [10-elk]
- **Traces:** OpenTelemetry Collector → Tempo/Jaeger; link from metrics (exemplars) and logs (trace id) to traces.
- **Alerting:** per service, **SLOs** with multi-window **burn-rate** alerts — those page. Everything else becomes a
  ticket or a dashboard. Alertmanager routing by team label, grouping, inhibition (cluster down suppresses its
  targets). Every page has a runbook link. Weekly review of every page: actionable? If not, delete or fix it. [9-monitoring/06]
- **Dashboards as code** in Git (Grafana provisioning), one standard service dashboard generated for all services.

**Failure modes:** the monitoring system itself fails → a dead-man's-switch alert (Watchdog) to an external service,
meta-monitoring of Prometheus; log pipeline back-pressure → buffering in Fluent Bit, drop debug logs first; cardinality
explosion → limits per scrape, alerts on series count.

**Measure success:** pages per week down, % pages actionable, outages detected by alerts before customers, MTTR.

---

## Design 4 — Zero-downtime database migration

**Part 1: VM PostgreSQL → RDS**
1. Create RDS (same major version, Multi-AZ, parameter group matching), sized from current metrics.
2. Initial copy + continuous replication: **AWS DMS** with CDC, or PostgreSQL **logical replication** (publication on
   the old DB, subscription on RDS). Verify row counts/checksums while it catches up.
3. Make the app's DB endpoint a config value (or a DNS name you control with a low TTL).
4. Cutover in a quiet window: stop writes briefly (maintenance mode or read-only for seconds), wait for replication lag
   = 0, sync sequences, switch the endpoint, verify, re-enable writes. Keep the old DB for rollback, optionally with
   reverse replication.
5. Rehearse the whole thing on staging with production-sized data; have a written rollback plan with a decision point.

**Part 2: rename a heavily used column — expand/contract**
1. **Expand:** add the new column (nullable — no table rewrite), deploy app version that writes **both** columns.
2. **Backfill** old rows in small batches (avoid long locks and replication lag).
3. Deploy app version that **reads the new** column (still writing both). Verify.
4. **Contract:** stop writing the old column; later drop it. Each step is backwards compatible, so any deploy can be
   rolled back.

**Failure modes:** replication lag during peak → schedule cutover off-peak, monitor lag; long locks on big tables →
`CREATE INDEX CONCURRENTLY`, batch updates; unknown consumers of the old column (reports, ETL) → find them before
contracting (query logs).

---

## Design 5 — IaC for a hand-built AWS estate

**Clarify:** what's critical (prod networking, databases, IAM)? Appetite for change? Who approves?

**Plan**
1. **Stop the bleeding:** CloudTrail everywhere, AWS Config to record changes, alerts on console changes in prod, SSO
   with least-privilege roles instead of shared admin users. Now you can answer "who changed this?".
2. **Foundations:** AWS Organizations, separate accounts (prod/staging/dev/security/log-archive), SCP guard rails,
   remote state (S3 + locking) and a CI pipeline for Terraform (plan on PR, apply on merge, OIDC). [6-terraform/09]
3. **New things only in code** from day one.
4. **Import existing resources incrementally**, most-changed first (security groups, IAM, DNS): `import` blocks or
   generated config (`terraform plan -generate-config-out`), then iterate until `terraform plan` shows **no changes**.
   Databases and networks last, with extra review.
5. **Remove console write access** for imported areas once they're in code (read-only + break-glass role with alerts).
6. Drift detection (nightly plan), module library for common patterns, docs and pairing so all 5 engineers can work this
   way.

**Trade-offs:** a big-bang rewrite is risky and blocks features → incremental import. Some resources may never be
worth importing (one-off legacy) — document and isolate them instead.
