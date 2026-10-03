#!/usr/bin/env bash
# analyze_logs.sh — answer questions from structured JSON logs with jq (what Kibana will do for you in Module 04)
#   ./analyze_logs.sh                 reads: docker compose logs app
#   ./analyze_logs.sh file.jsonl      reads a file
set -euo pipefail
cd "$(dirname "$0")"
if (( $# )); then src() { cat "$1"; }; else src() { docker compose logs --no-log-prefix app; }; fi

# keep only lines that are JSON objects (startup noise from other tools would break jq)
logs=$(src "$@" | grep '^{' || true)
[[ -n $logs ]] || { echo "no JSON log lines found — is LOG_FORMAT=json set?" >&2; exit 1; }

echo "== Requests by status code"
jq -r 'select(.http) | .http.response.status_code' <<< "$logs" | sort | uniq -c | sort -rn

echo "== Log levels"
jq -r '.log.level' <<< "$logs" | sort | uniq -c | sort -rn

echo "== The 5 slowest requests (ms, path)"
jq -r 'select(.event) | "\(.event.duration / 1e6 | floor)\t\(.url.path)"' <<< "$logs" | sort -rn | head -5

echo "== p95 latency in ms (all requests)"
jq -s '[.[] | select(.event) | .event.duration / 1e6] | sort | .[(length * 0.95 | floor)] | floor' <<< "$logs"

echo "== Last 3 errors, as the on-call engineer would want them"
jq -c 'select(.log.level == "error") | {time: ."@timestamp", path: .url.path, status: .http.response.status_code, host: .host.name}' \
    <<< "$logs" | tail -3
