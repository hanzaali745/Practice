#!/usr/bin/env bash
# ops_tour.sh — operate Elasticsearch like production: security, data streams + ILM, users, API keys, snapshots.
# Every step checks its own result. Start the stack first: docker compose up -d --wait
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck disable=SC1091  # .env is optional and created by you
if [[ -f .env ]]; then set -a; . ./.env; set +a; fi
ES=${ES:-http://localhost:9200}
PW=${ELASTIC_PASSWORD:-bootcamp-elastic}
DEV_PW=${DEV_PASSWORD:-bootcamp-dev}

es()     { curl -fsS -u "elastic:$PW" -H 'Content-Type: application/json' "$@"; }      # as the superuser
code()   { curl -s -o /dev/null -w '%{http_code}' "$@"; }                               # just the HTTP status
say()    { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()     { echo "  ✅ $*"; }
expect() {
    local want=$1 got=$2 what=$3
    if [[ $got == "$want" ]]; then ok "$what ($got)"; else echo "  ❌ $what: got $got, want $want"; exit 1; fi
}
count()  { es "$ES/$1/_count" | python3 -c 'import json,sys; print(json.load(sys.stdin)["count"])'; }

say "1. Security is on"
expect 401 "$(code "$ES/")" "anonymous request is rejected"
expect 200 "$(code -u "elastic:$PW" "$ES/")" "elastic superuser works"

say "2. ILM policy: roll over daily (or at 10 GB per shard), delete after 7 days"
es -X PUT "$ES/_ilm/policy/demo-logs-7d" -d '{
  "policy": {"phases": {
    "hot":    {"actions": {"rollover": {"max_age": "1d", "max_primary_shard_size": "10gb"}}},
    "delete": {"min_age": "7d", "actions": {"delete": {}}}
  }}}' > /dev/null
ok "policy demo-logs-7d"

say "3. Data stream template: logs-demoapp-* → data stream, 0 replicas, ILM policy, ECS-ish mappings"
es -X PUT "$ES/_index_template/logs-demoapp" -d '{
  "index_patterns": ["logs-demoapp-*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {"number_of_replicas": 0, "index.lifecycle.name": "demo-logs-7d"},
    "mappings": {"properties": {
      "@timestamp": {"type": "date"}, "message": {"type": "text"},
      "log": {"properties": {"level": {"type": "keyword"}}},
      "host": {"properties": {"name": {"type": "keyword"}}}
    }}
  }}' > /dev/null
ok "template logs-demoapp (priority 500 beats the built-in logs-*-* template's 100)"

say "4. Write to the data stream (append-only: op_type create), then roll it over"
for i in 1 2 3; do
    es -X POST "$ES/logs-demoapp-default/_doc?refresh=true" \
        -d "{\"@timestamp\": \"$(date -u +%FT%TZ)\", \"message\": \"line $i\", \"log\": {\"level\": \"info\"}, \"host\": {\"name\": \"web-1\"}}" > /dev/null
done
es -X POST "$ES/logs-demoapp-default/_rollover" > /dev/null        # what ILM does for you daily
es "$ES/_data_stream/logs-demoapp-default" | python3 -c '
import json, sys
ds = json.load(sys.stdin)["data_streams"][0]
print("  ✅ backing indices:", [i["index_name"] for i in ds["indices"]], "| ILM:", ds.get("ilm_policy"))'
expect 3 "$(count logs-demoapp-default)" "documents across backing indices"

say "5. A read-only role and a user for developers"
es -X PUT "$ES/_security/role/logs_reader" -d '{
  "indices": [{"names": ["logs-demoapp-*", "demo-logs-*"], "privileges": ["read", "view_index_metadata"]}],
  "applications": [{"application": "kibana-.kibana", "privileges": ["feature_discover.read", "feature_dashboard.read"], "resources": ["*"]}]
}' > /dev/null
es -X PUT "$ES/_security/user/dev" -d "{\"password\": \"$DEV_PW\", \"roles\": [\"logs_reader\"], \"full_name\": \"A Developer\"}" > /dev/null
expect 200 "$(code -u "dev:$DEV_PW" "$ES/logs-demoapp-default/_search")" "dev can search logs"
expect 403 "$(code -u "dev:$DEV_PW" -X POST -H 'Content-Type: application/json' "$ES/logs-demoapp-default/_doc" -d '{"@timestamp":"2026-01-01T00:00:00Z"}')" "dev cannot write"
expect 403 "$(code -u "dev:$DEV_PW" -X DELETE "$ES/_data_stream/logs-demoapp-default")" "dev cannot delete"

say "6. An API key for a log shipper: may ONLY append to logs-demoapp-*, expires in 30 days"
key=$(es -X POST "$ES/_security/api_key" -d '{
  "name": "filebeat-web-1", "expiration": "30d",
  "role_descriptors": {"shipper": {"indices": [{"names": ["logs-demoapp-*"], "privileges": ["create_doc", "auto_configure"]}]}}
}' | python3 -c 'import json,sys; print(json.load(sys.stdin)["encoded"])')
expect 201 "$(code -X POST -H "Authorization: ApiKey $key" -H 'Content-Type: application/json' "$ES/logs-demoapp-default/_doc" \
    -d "{\"@timestamp\": \"$(date -u +%FT%TZ)\", \"message\": \"from the shipper\"}")" "shipper key can append"
expect 403 "$(code -H "Authorization: ApiKey $key" "$ES/logs-demoapp-default/_search")" "shipper key cannot read"
es -X POST "$ES/logs-demoapp-default/_refresh" > /dev/null

say "7. Snapshot, disaster, restore"
es -X PUT "$ES/_snapshot/lab" -d '{"type": "fs", "settings": {"location": "/snapshots/lab"}}' > /dev/null
before=$(count logs-demoapp-default)
es -X PUT "$ES/_snapshot/lab/snap-$(date +%s)?wait_for_completion=true" \
    -d '{"indices": "logs-demoapp-*", "include_global_state": false}' \
  | python3 -c 'import json,sys; s=json.load(sys.stdin)["snapshot"]; print("  ✅ snapshot", s["snapshot"], s["state"], s["shards"])'
es -X DELETE "$ES/_data_stream/logs-demoapp-default" > /dev/null
expect 404 "$(code -u "elastic:$PW" "$ES/logs-demoapp-default/_count")" "💥 data stream deleted"
latest=$(es "$ES/_snapshot/lab/_all" | python3 -c 'import json,sys; print(json.load(sys.stdin)["snapshots"][-1]["snapshot"])')
es -X POST "$ES/_snapshot/lab/$latest/_restore?wait_for_completion=true" \
    -d '{"indices": "logs-demoapp-*", "include_global_state": false}' > /dev/null
expect "$before" "$(count logs-demoapp-default)" "restored all documents"

say "8. Health at a glance"
es "$ES/_cluster/health" | python3 -c 'import json,sys; h=json.load(sys.stdin); print("  status:", h["status"], "| nodes:", h["number_of_nodes"], "| unassigned shards:", h["unassigned_shards"])'
es "$ES/_nodes/stats/jvm" | python3 -c 'import json,sys; n=list(json.load(sys.stdin)["nodes"].values())[0]; print("  JVM heap used:", n["jvm"]["mem"]["heap_used_percent"], "%")'
es "$ES/_cat/indices/.ds-logs-demoapp-*?v&h=index,health,docs.count,store.size&s=index"
echo; echo "✅ operations tour complete"
