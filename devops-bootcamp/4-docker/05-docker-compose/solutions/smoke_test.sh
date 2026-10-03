#!/usr/bin/env bash
#
# smoke_test.sh — bring the stack up, test it through nginx, tear it down
# Usage: smoke_test.sh [dev|prod]
#
set -euo pipefail
cd "$(dirname "$0")"

mode="${1:-dev}"
case "$mode" in
    dev)  files=(-f compose.yaml -f compose.override.yaml); expect="DEV" ;;
    prod) files=(-f compose.yaml -f compose.prod.yaml);     expect="PROD" ;;
    *)    echo "Usage: $0 [dev|prod]" >&2; exit 2 ;;
esac
port="${PROXY_PORT:-8080}"
base="http://localhost:$port"

cleanup() { docker compose "${files[@]}" down -v > /dev/null 2>&1 || true; }
trap cleanup EXIT

fail() { echo "❌ $*" >&2; docker compose "${files[@]}" ps >&2; exit 1; }

echo "== starting $mode stack"
log=$(mktemp)
if ! docker compose "${files[@]}" up -d --build --wait --wait-timeout 120 > "$log" 2>&1; then
    cat "$log" >&2
    fail "stack did not become healthy"
fi
rm -f "$log"

echo "== checks through nginx ($base)"
body=$(curl -sf "$base/") || fail "/ did not respond"
[[ $body == *"$expect"* ]] || fail "/ should mention $expect, got: $body"
echo "✅ /        $body"

curl -sf "$base/health" | grep -q '"ok"' || fail "/health failed"
echo "✅ /health"

first=$(curl -sf "$base/visits" | python3 -c 'import json,sys; print(json.load(sys.stdin)["visits"])')
second=$(curl -sf "$base/visits" | python3 -c 'import json,sys; print(json.load(sys.stdin)["visits"])')
(( second == first + 1 )) || fail "/visits did not increase ($first -> $second)"
echo "✅ /visits  $first -> $second (stored in Redis)"

hosts=$(for _ in $(seq 12); do curl -sf "$base/" | python3 -c 'import json,sys; print(json.load(sys.stdin)["hostname"])'; done | sort -u | wc -l)
(( hosts >= 2 )) || fail "expected several replicas to answer, got $hosts"
echo "✅ load balancing: $hosts different containers answered 12 requests"

echo "🎉 smoke test passed ($mode)"
