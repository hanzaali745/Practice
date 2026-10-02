#!/usr/bin/env bash
# Lab 3 — retry with exponential backoff
set -euo pipefail

retry() {
    local attempts="$1" delay="$2"; shift 2
    local n=1
    until "$@"; do
        if (( n >= attempts )); then
            echo "failed after $n attempts: $*" >&2
            return 1
        fi
        echo "attempt $n failed, retrying in ${delay}s..." >&2
        sleep "$delay"
        (( ++n ))
        delay=$(( delay * 2 ))
    done
    echo "succeeded on attempt $n" >&2
}

counter_file=$(mktemp)
trap 'rm -f "$counter_file"' EXIT
echo 0 > "$counter_file"

# Fails on the first two calls, succeeds on the third
flaky() {
    local calls
    calls=$(( $(cat "$counter_file") + 1 ))
    echo "$calls" > "$counter_file"
    (( calls >= 3 ))
}

retry 5 1 flaky
echo 0 > "$counter_file"
retry 2 1 flaky || echo "As expected, 2 attempts were not enough"
