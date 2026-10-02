#!/usr/bin/env bash
# Lab 2 — check hosts in parallel and collect exit codes
# Usage: ./parallel_check.sh [--sequential]
set -uo pipefail

hosts=(web-01 web-02 web-03 web-04 db-01 db-02 cache-01 lb-01)

check_host() {
    local host="$1"
    sleep $(( RANDOM % 3 ))
    if (( RANDOM % 5 == 0 )); then
        echo "❌ $host"
        return 1
    fi
    echo "✅ $host"
}

SECONDS=0
failed=0

if [[ ${1:-} == "--sequential" ]]; then
    for h in "${hosts[@]}"; do
        check_host "$h" || (( ++failed ))
    done
else
    declare -A pid_to_host=()
    for h in "${hosts[@]}"; do
        check_host "$h" &
        pid_to_host[$!]="$h"
    done
    for pid in "${!pid_to_host[@]}"; do
        wait "$pid" || (( ++failed ))
    done
fi

echo "Checked ${#hosts[@]} hosts in ${SECONDS}s, $failed failed"
(( failed == 0 ))
