#!/usr/bin/env bash
# es_tour.sh — the Elasticsearch REST API, step by step (start the stack first: docker compose up -d)
set -euo pipefail
cd "$(dirname "$0")"
ES=${ES:-http://localhost:9200}
es() { local method=$1 path=$2; shift 2; curl -fsS -X "$method" "$ES$path" -H 'Content-Type: application/json' "$@"; echo; }
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

say "1. Is the cluster healthy?   (green = all copies placed; yellow = replicas missing — normal on 1 node)"
es GET "/_cluster/health?pretty" | grep -E '"(status|number_of_nodes|active_shards)"'

say "2. An index template: every index named demo-logs-* gets these settings and field types"
# (not logs-*-*: Elasticsearch reserves that pattern for data streams with a built-in template — Module 05)
es PUT /_index_template/demo-logs -d '{
  "index_patterns": ["demo-logs-*"],
  "template": {
    "settings": {"number_of_shards": 1, "number_of_replicas": 0},
    "mappings": {
      "properties": {
        "@timestamp":  {"type": "date"},
        "message":     {"type": "text"},
        "log":         {"properties": {"level": {"type": "keyword"}}},
        "url":         {"properties": {"path":  {"type": "keyword"}}},
        "http":        {"properties": {"response": {"properties": {"status_code": {"type": "short"}}}}},
        "event":       {"properties": {"duration": {"type": "long"}}},
        "client":      {"properties": {"ip": {"type": "ip"}}},
        "host":        {"properties": {"name": {"type": "keyword"}}},
        "service":     {"properties": {"name": {"type": "keyword"}, "version": {"type": "keyword"}}}
      }
    }
  }
}'

say "3. Index ONE document (the index is created automatically from the template)"
es POST "/demo-logs-tour/_doc/1?refresh=true" -d '{"@timestamp": "2026-10-03T10:00:00Z", "message": "GET / 200 3.1ms",
  "log": {"level": "info"}, "url": {"path": "/"}, "http": {"response": {"status_code": 200}}, "host": {"name": "web-1"}}'
es GET "/demo-logs-tour/_doc/1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["_source"]["message"])'

say "4. Bulk-load 2000 generated log lines (the _bulk API: one action line + one document line each)"
python3 make_sample_logs.py 2000 | sed 's/^/{"index":{}}\n/' > /tmp/bulk.ndjson
curl -fsS -X POST "$ES/demo-logs-sample/_bulk?refresh=true" -H 'Content-Type: application/x-ndjson' \
    --data-binary @/tmp/bulk.ndjson | python3 -c 'import json,sys; r=json.load(sys.stdin); print("errors:", r["errors"], "items:", len(r["items"]))'
es GET "/_cat/indices/demo-logs-*?v&h=index,docs.count,store.size"

say "5. Full-text search: messages containing 500"
es POST "/demo-logs-sample/_search?size=0" -d '{"query": {"match": {"message": "500"}}}' \
    | python3 -c 'import json,sys; print("hits:", json.load(sys.stdin)["hits"]["total"]["value"])'

say "6. Exact filters with bool: errors on web-3 in the last 6 hours"
es POST "/demo-logs-sample/_search?size=2" -d '{
  "query": {"bool": {"filter": [
    {"term": {"log.level": "error"}},
    {"term": {"host.name": "web-3"}},
    {"range": {"@timestamp": {"gte": "now-6h"}}}
  ]}},
  "sort": [{"@timestamp": "desc"}], "_source": ["@timestamp", "message", "host.name"]
}' | python3 -c 'import json,sys; r=json.load(sys.stdin)["hits"]; print("total:", r["total"]["value"]); [print(" ", h["_source"]) for h in r["hits"]]'

say "7. Aggregations: requests per status code, p95 latency per host, errors per 6 hours"
es POST "/demo-logs-sample/_search?size=0" -d '{
  "aggs": {
    "by_status":  {"terms": {"field": "http.response.status_code"}},
    "by_host":    {"terms": {"field": "host.name"}, "aggs": {"p95_ns": {"percentiles": {"field": "event.duration", "percents": [95]}}}},
    "errors_per_6h": {"filter": {"term": {"log.level": "error"}},
                        "aggs": {"h": {"date_histogram": {"field": "@timestamp", "fixed_interval": "6h"}}}}
  }
}' | python3 -c '
import json, sys
a = json.load(sys.stdin)["aggregations"]
print("  status:", {b["key"]: b["doc_count"] for b in a["by_status"]["buckets"]})
print("  p95 ms:", {b["key"]: round(b["p95_ns"]["values"]["95.0"] / 1e6, 1) for b in a["by_host"]["buckets"]})
print("  errors per 6h:", [b["doc_count"] for b in a["errors_per_6h"]["h"]["buckets"]])'

say "8. Who scans for /wp-login.php? (top client IPs on 404s)"
es POST "/demo-logs-sample/_search?size=0" -d '{"query": {"term": {"http.response.status_code": 404}},
  "aggs": {"ips": {"terms": {"field": "client.ip", "size": 3}}}}' \
    | python3 -c 'import json,sys; print(" ", [(b["key"], b["doc_count"]) for b in json.load(sys.stdin)["aggregations"]["ips"]["buckets"]])'

say "9. Clean up the tour index"
es DELETE /demo-logs-tour
