#!/usr/bin/env bash
# kibana_setup.sh — data view + saved searches/visualizations/dashboard, as the elastic user
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck disable=SC1091  # .env is optional
if [[ -f .env ]]; then set -a; . ./.env; set +a; fi
KB=${KIBANA:-http://localhost:5601}
kb() { curl -fsS -u "elastic:${ELASTIC_PASSWORD:-bootcamp-elastic}" -H 'kbn-xsrf: true' "$@"; }

until kb "$KB/api/status" 2>/dev/null | grep -q '"level":"available"'; do sleep 5; done
kb -X POST "$KB/api/data_views/data_view" -H 'Content-Type: application/json' -d '{
  "override": true,
  "data_view": {"id": "demo-logs", "title": "logs-demoapp-*,logs-nginx-*", "name": "demo platform logs", "timeFieldName": "@timestamp"}
}' > /dev/null
kb -X POST "$KB/api/saved_objects/_import?overwrite=true" -F file=@kibana/demo-logs.ndjson \
    | python3 -c 'import json, sys; r = json.load(sys.stdin); print("kibana import success:", r["success"], "objects:", r["successCount"])'
