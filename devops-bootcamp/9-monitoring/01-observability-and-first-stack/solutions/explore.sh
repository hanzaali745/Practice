#!/usr/bin/env bash
# explore.sh — ask Prometheus questions through its HTTP API (what the UI does for you)
#   ./explore.sh                     the standard tour
#   ./explore.sh 'up == 0'           your own PromQL query
set -euo pipefail
PROM=${PROM:-http://localhost:9090}

query() {                                     # print "labels => value" for an instant query
    curl -fsS --get "$PROM/api/v1/query" --data-urlencode "query=$1" | python3 -c '
import json, sys
for r in json.load(sys.stdin)["data"]["result"]:
    labels = ",".join(k + "=" + v for k, v in sorted(r["metric"].items())) or "(no labels)"
    print("  " + labels + " => " + r["value"][1])'
}

if (( $# )); then query "$1"; exit; fi

echo "== Which targets are up? (1 = scraped OK)"
query 'up'
echo "== How many requests has demo-app handled, by path and code?"
query 'sum by (path, code) (http_requests_total)'
echo "== Machine: free memory in GiB"
query 'node_memory_MemAvailable_bytes / 1024^3'
echo "== Machine: root filesystem % used"
query '100 * (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})'
echo "== Prometheus itself: how many time series is it storing?"
query 'prometheus_tsdb_head_series'
