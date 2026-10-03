#!/usr/bin/env bash
# promql_lab.sh — the Lab 1-3 answers, run against the live stack (start it and wait ~2 minutes first)
set -euo pipefail
PROM=${PROM:-http://localhost:9090}

ask() {                                   # ask "QUESTION" 'PROMQL'
    printf '\n\033[1m%s\033[0m\n  %s\n' "$1" "$2"
    curl -fsS --get "$PROM/api/v1/query" --data-urlencode "query=$2" | python3 -c '
import json, sys
res = json.load(sys.stdin)["data"]["result"]
for r in res or []:
    labels = ",".join(k + "=" + v for k, v in sorted(r["metric"].items())) or "(no labels)"
    print("  → " + labels + " = " + str(round(float(r["value"][1]), 4)))
if not res:
    print("  → (empty result)")'
}

ask "1. Requests per second, per instance"            'sum by (instance) (rate(http_requests_total[1m]))'
ask "2. Requests per second, whole service"           'sum(rate(http_requests_total[1m]))'
ask "3. Requests per second by status code"           'sum by (code) (rate(http_requests_total[1m]))'
ask "4. Error ratio (5xx / all)"                      'sum(rate(http_requests_total{code=~"5.."}[1m])) / sum(rate(http_requests_total[1m]))'
ask "5. Requests in the last 5 minutes"               'sum(increase(http_requests_total[5m]))'
ask "6. p95 latency in seconds (try 0.5 and 0.99)"  'histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[1m])))'
ask "7. p95 latency per path"                         'histogram_quantile(0.95, sum by (path, le) (rate(http_request_duration_seconds_bucket[1m])))'
ask "8. Average latency (sum / count)"                'sum(rate(http_request_duration_seconds_sum[1m])) / sum(rate(http_request_duration_seconds_count[1m]))'
ask "9. Busiest path"                                 'topk(1, sum by (path) (rate(http_requests_total[1m])))'
ask "10. Traffic now vs 1 minute ago (ratio)"         'sum(rate(http_requests_total[1m])) / sum(rate(http_requests_total[1m] offset 1m))'
ask "11. Which version runs where?"                  'sum by (instance, version) (demo_app_build_info)'
ask "12. Instances up for more than 1 minute"         'time() - process_start_time_seconds > 60'
ask "13. Recording rule: error ratio (Lab 4)"         'job:http_requests_errors:ratio_rate5m'
ask "14. Recording rule: p95 (Lab 4)"                 'job:http_request_duration_seconds:p95_5m'
