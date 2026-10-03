# ELK Module 02 — Elasticsearch 🟢

## 🎯 Objectives
- Explain the ELK stack and where Elasticsearch fits
- Run a single-node Elasticsearch and check cluster health
- Understand indices, documents, shards and replicas
- Control field types with **mappings** and **index templates** (`text` vs `keyword`)
- Load data with the **bulk API**; search with `match`, `term`, `bool` and `range`
- Answer questions with **aggregations** (terms, percentiles, date histograms)

## 🧠 Why DevOps engineers care
Elasticsearch is the search engine behind most centralised logging (and plenty of product search). DevOps engineers
run it, size it, debug red clusters, and write the queries that find "every failed checkout from version 2.1.0 in the
last hour". Knowing the REST API directly — not just Kibana — is what lets you automate and troubleshoot it.

---

## 📖 Lesson 2.1 — The stack

```
 apps / servers ──► Beats (Filebeat) ──► [Logstash: parse, enrich] ──► Elasticsearch ◄── Kibana (search, dashboards)
                     ship logs               optional                    store + index        you
```
**E**lasticsearch stores and searches, **L**ogstash transforms, **K**ibana shows. "Elastic Stack" adds **Beats**.
Open-source alternative: **OpenSearch** (a fork, very similar APIs). Different approach: **Grafana Loki** (indexes
only labels, cheaper, less powerful search).

## 📖 Lesson 2.2 — Run it

```bash
cd ~/Practice/devops-bootcamp/10-elk/02-elasticsearch/solutions
docker compose up -d --wait
curl -s localhost:9200                                   # name, version, "You Know, for Search"
curl -s 'localhost:9200/_cluster/health?pretty'          # green / yellow / red
curl -s 'localhost:9200/_cat/nodes?v'  ;  curl -s 'localhost:9200/_cat/indices?v'
```
Security is **off** in Modules 02–04 so you can focus on the APIs; Module 05 turns it on. Two settings in
[`compose.yaml`](solutions/compose.yaml) worth knowing:
- `ES_JAVA_OPTS: -Xms512m -Xmx512m` — heap ≈ half the memory, both values equal
- disk **watermarks** — by default Elasticsearch stops placing data when the disk is 90% full and the cluster turns
  **red**. The lab uses absolute free-space limits instead. (`_cluster/allocation/explain` tells you why a shard isn't
  placed — that's how this was found.)

## 📖 Lesson 2.3 — Indices, documents, shards

| Concept | Like… | Example |
|---------|-------|---------|
| **Index** | a table | `demo-logs-sample` |
| **Document** | a row (JSON) | one log line |
| **Mapping** | the schema | `host.name` is a `keyword` |
| **Shard** | a slice of an index, the unit of scaling | 1 primary shard |
| **Replica** | a copy of a shard on another node | 0 on a single node (otherwise the cluster stays yellow) |

## 📖 Lesson 2.4 — Mappings and index templates

```bash
curl -X PUT localhost:9200/_index_template/demo-logs -H 'Content-Type: application/json' -d '{
  "index_patterns": ["demo-logs-*"],
  "template": {
    "settings": {"number_of_shards": 1, "number_of_replicas": 0},
    "mappings": {"properties": {
      "@timestamp": {"type": "date"},
      "message":    {"type": "text"},                           # analysed: full-text search
      "host":       {"properties": {"name": {"type": "keyword"}}},   # exact: filter, sort, aggregate
      "client":     {"properties": {"ip": {"type": "ip"}}}}}}}'
```
**`text`** is split into words for searching ("GET", "500"); **`keyword`** is kept whole for exact matches and
aggregations. Without a template, Elasticsearch guesses ("dynamic mapping") — and guesses wrong sometimes. You can't
change a field's type later without reindexing, so decide up front.

> Names matching `logs-*-*` are reserved: a built-in template turns them into **data streams** (Module 05). That's why
> this module uses `demo-logs-*`.

## 📖 Lesson 2.5 — Write and search

```bash
POST /demo-logs-tour/_doc            {...}                    # index one document
POST /demo-logs-sample/_bulk         {"index":{}}\n{...}\n    # many at once — always use bulk for volume
GET  /demo-logs-tour/_doc/1
POST /demo-logs-sample/_search
```
```json
{"query": {"bool": {
   "must":   [{"match": {"message": "timeout"}}],
   "filter": [{"term": {"log.level": "error"}},
              {"term": {"host.name": "web-3"}},
              {"range": {"@timestamp": {"gte": "now-6h"}}}]}},
 "sort": [{"@timestamp": "desc"}], "size": 20}
```
Use `filter` for yes/no conditions (cached, no scoring) and `must`/`should` for relevance search.

## 📖 Lesson 2.6 — Aggregations

```json
{"size": 0, "aggs": {
   "by_status": {"terms": {"field": "http.response.status_code"}},
   "by_host":   {"terms": {"field": "host.name"},
                 "aggs": {"p95": {"percentiles": {"field": "event.duration", "percents": [95]}}}},
   "over_time": {"date_histogram": {"field": "@timestamp", "fixed_interval": "1h"}}}}
```
That's the logs version of PromQL: counts by status, p95 per host, errors over time — computed from raw events.
[`es_tour.sh`](solutions/es_tour.sh) runs every step of this module against 2000 generated log lines
([`make_sample_logs.py`](solutions/make_sample_logs.py)).

---

## ⚠️ Common mistakes
- Letting dynamic mapping decide types (an IP as `text`, a status code as `keyword` *and* `long` in two indices)
- Aggregating on a `text` field (error) — use the `keyword` field
- Indexing one document per request at volume instead of `_bulk`
- Too many small shards (each costs memory) — aim for shards of 10–50 GB
- Panicking at **yellow** on a single node — replicas simply have nowhere to go

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --wait`, then `./es_tour.sh`.

### Lab 1 ⭐ — Explore
Start Elasticsearch; check health, nodes and indices with `_cluster/health` and `_cat`. Create an index with
`"number_of_replicas": 1` — why does the cluster turn yellow? Use `_cluster/allocation/explain` to get Elasticsearch to
tell you, then set replicas back to 0 with `PUT /<index>/_settings`.

### Lab 2 ⭐⭐ — Mappings
Create the `demo-logs` index template with correct types. Index one document, then check `GET /demo-logs-tour/_mapping`.
Index a document with a new, unexpected field and see what dynamic mapping chose.

### Lab 3 ⭐⭐ — Bulk and search
Generate 2000 log lines and bulk-load them. Write searches for: messages containing "500"; errors on `web-3` in the
last 6 hours (newest first); 404s from one client IP.

### Lab 4 ⭐⭐⭐ — Aggregations
Requests per status code; p95 latency per host; errors per 6 hours; top 3 client IPs hitting 404s (scanners!); errors
per service version. Which version has the highest error ratio?

---

## ✅ Checkpoint
- [ ] I can run Elasticsearch, read cluster health and explain green/yellow/red
- [ ] I know indices, documents, shards and replicas, and `text` vs `keyword`
- [ ] I define mappings with index templates before data arrives
- [ ] I can bulk-load, search with bool queries, and aggregate

👉 Next: [Module 03 — Shipping & Parsing Logs](../03-shipping-and-parsing/README.md)
