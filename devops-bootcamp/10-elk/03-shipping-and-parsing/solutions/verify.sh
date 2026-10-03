#!/usr/bin/env bash
# verify.sh — did the logs arrive, and were they parsed? (run ~2 minutes after docker compose up)
set -euo pipefail
ES=${ES:-http://localhost:9200}
search() { curl -fsS -X POST "$ES/demo-logs-*/_search" -H 'Content-Type: application/json' -d "$1"; }

echo "== Indices"
curl -fsS "$ES/_cat/indices/demo-logs-*?v&h=index,docs.count&s=index"

echo "== Documents per service and level"
search '{"size": 0, "aggs": {"svc": {"terms": {"field": "service.name"},
         "aggs": {"lvl": {"terms": {"field": "log.level"}}}}}}' | python3 -c '
import json, sys
for b in json.load(sys.stdin)["aggregations"]["svc"]["buckets"]:
    levels = {lv["key"]: lv["doc_count"] for lv in b["lvl"]["buckets"]}
    print("  ", b["key"].ljust(10), str(b["doc_count"]).rjust(6), levels)'

echo "== nginx lines grok could NOT parse"
search '{"size": 0, "query": {"term": {"tags": "_grokparsefailure_nginx"}}}' \
    | python3 -c 'import json, sys; print("  ", json.load(sys.stdin)["hits"]["total"]["value"])'

echo "== One parsed nginx line and one app line"
for svc in nginx demo-app; do
    search "{\"size\": 1, \"query\": {\"bool\": {\"filter\": [{\"term\": {\"service.name\": \"$svc\"}}, {\"exists\": {\"field\": \"http.response.status_code\"}}]}}, \"sort\": [{\"@timestamp\": \"desc\"}]}" \
        | python3 -c '
import json, sys
s = json.load(sys.stdin)["hits"]["hits"][0]["_source"]
print("  ", {k: s.get(k) for k in ("@timestamp", "service", "log", "url", "http", "client", "container")})'
done
