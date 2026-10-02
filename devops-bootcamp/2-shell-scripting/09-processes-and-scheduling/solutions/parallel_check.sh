#!/bin/sh
# Lab 2 — check hosts in parallel and collect exit codes
# Usage: sh parallel_check.sh [--sequential]

HOSTS="web-01 web-02 web-03 web-04 db-01 db-02 cache-01 lb-01"

random_byte() { od -An -N1 -tu1 /dev/urandom | tr -d ' '; }

check_host() {
    sleep $(($(random_byte) % 3))                 # pretend work: 0-2 seconds
    if [ $(($(random_byte) % 5)) -eq 0 ]; then    # ~20% of checks fail
        echo "❌ $1"
        return 1
    fi
    echo "✅ $1"
}

start=$(date +%s)
failed=0
total=0

if [ "${1:-}" = "--sequential" ]; then
    for h in $HOSTS; do
        total=$((total + 1))
        check_host "$h" || failed=$((failed + 1))
    done
else
    pids=""
    for h in $HOSTS; do
        total=$((total + 1))
        check_host "$h" &
        pids="$pids $!"
    done
    for pid in $pids; do
        wait "$pid" || failed=$((failed + 1))
    done
fi

echo "Checked $total hosts in $(($(date +%s) - start))s, $failed failed"
[ "$failed" -eq 0 ]
