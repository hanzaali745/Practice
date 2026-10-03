#!/usr/bin/env bash
# kibana_setup.sh — Kibana as code: create the data view and import searches, visualizations and the dashboard
set -euo pipefail
cd "$(dirname "$0")"
KB=${KIBANA:-http://localhost:5601}
kb() { curl -fsS -H 'kbn-xsrf: true' "$@"; }      # every Kibana write API needs the kbn-xsrf header

echo "== waiting for Kibana"
until kb "$KB/api/status" 2>/dev/null | grep -q '"level":"available"'; do sleep 5; done

echo "== data view demo-logs-* (id demo-logs)"
kb -X POST "$KB/api/data_views/data_view" -H 'Content-Type: application/json' -d '{
  "override": true,
  "data_view": {"id": "demo-logs", "title": "demo-logs-*", "name": "demo logs", "timeFieldName": "@timestamp"}
}' > /dev/null

echo "== import saved objects from kibana/demo-logs.ndjson"
kb -X POST "$KB/api/saved_objects/_import?overwrite=true" -F file=@kibana/demo-logs.ndjson \
    | python3 -c 'import json, sys; r = json.load(sys.stdin); print("  success:", r["success"], "imported:", r["successCount"], r.get("errors", ""))'

echo "== open: $KB/app/dashboards#/view/demo-logs-overview"
