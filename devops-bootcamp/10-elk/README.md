# 🔎 Phase 10: Logging with ELK (Elasticsearch, Logstash, Kibana)

> **Before you start:** finish Phase 9 and set `vm.max_map_count` ([Part 3 setup](../00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md),
> Step 5). Elasticsearch, Logstash and Kibana together want **~4 GB of free RAM** — close other stacks first
> (`docker compose down` in older labs).
> **It's free and local:** Docker Compose stacks with the official Elastic images (version 9.5.4). demo-app writes ECS JSON
> logs when `LOG_FORMAT=json`. Module 06 uses your kind cluster.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Logging Fundamentals](01-logging-fundamentals/README.md) | 🟢 | levels, structured JSON/ECS, correlation ids, jq, rotation |
| 02 | [Elasticsearch](02-elasticsearch/README.md) | 🟢 | indices, mappings, templates, bulk, search, aggregations |
| 03 | [Shipping & Parsing Logs](03-shipping-and-parsing/README.md) | 🟡 | Filebeat, Logstash pipelines, grok, date, ECS normalisation |
| 04 | [Kibana](04-kibana/README.md) | 🟡 | Discover, KQL, visualizations, dashboards as code |
| 05 | [Operating Elasticsearch](05-operating-elasticsearch/README.md) | 🔴 | security, roles, API keys, data streams, ILM, snapshots |
| 06 | [Logging on Kubernetes](06-kubernetes-logging/README.md) | 🔴 | Fluent Bit DaemonSet, CRI logs, metadata, troubleshooting |
| 07 | [ELK Capstone](07-capstone/README.md) | 🏆 | secured centralised logging with retention, dashboards and alerts |

## Cheat sheet

```bash
GET _cluster/health   GET _cat/indices?v   GET _cat/shards?v   GET _cluster/allocation/explain
PUT _index_template/x {...}   POST idx/_bulk   POST idx/_search {"query": {"bool": {"filter": [...]}}}
PUT _ilm/policy/x {...}   GET ds/_ilm/explain   POST ds/_rollover   GET _data_stream
PUT _security/role/x   PUT _security/user/x   POST _security/api_key   DELETE _security/api_key
PUT _snapshot/repo {...}   PUT _snapshot/repo/snap?wait_for_completion=true   POST _snapshot/repo/snap/_restore
logstash --config.test_and_exit -f pipeline.conf     filebeat test config / test output     fluent-bit --dry-run
```
```
KQL:  log.level : error and host.name : "web-3"   http.response.status_code >= 500   url.path : /wp-*   client.ip : 10.0.0.0/8
```

## 🏅 ELK expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Write structured JSON logs with ECS fields and correlation ids; keep secrets out; rotate everywhere
- [ ] Explain indices, shards, replicas, mappings (`text` vs `keyword`) and fix a red or yellow cluster
- [ ] Search with bool queries and answer questions with aggregations
- [ ] Ship logs with Filebeat or Fluent Bit and parse JSON and plain text (grok, date) into one schema
- [ ] Investigate fast in Kibana with KQL, and keep data views and dashboards in Git
- [ ] Secure Elasticsearch with least-privilege roles, users and API keys
- [ ] Manage retention with data streams and ILM, and prove backups with a snapshot restore
- [ ] Run a log DaemonSet on Kubernetes and troubleshoot missing logs
- [ ] Alert on log patterns and explain when to use logs vs metrics

👉 Start: [Module 01 — Logging Fundamentals](01-logging-fundamentals/README.md)
