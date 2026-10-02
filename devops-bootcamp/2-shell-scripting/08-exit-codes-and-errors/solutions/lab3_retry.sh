#!/bin/sh
# Lab 3 — retry with exponential backoff
set -eu

retry() {
    retry_max="$1"
    retry_delay="$2"
    shift 2
    retry_n=1
    until "$@"; do
        if [ "$retry_n" -ge "$retry_max" ]; then
            echo "failed after $retry_n attempts: $*" >&2
            return 1
        fi
        echo "attempt $retry_n failed, retrying in ${retry_delay}s..." >&2
        sleep "$retry_delay"
        retry_n=$((retry_n + 1))
        retry_delay=$((retry_delay * 2))
    done
    echo "succeeded on attempt $retry_n" >&2
}

counter_file=$(mktemp)
trap 'rm -f "$counter_file"' EXIT
echo 0 > "$counter_file"

# Fails on the first two calls, succeeds on the third
flaky() {
    calls=$(($(cat "$counter_file") + 1))
    echo "$calls" > "$counter_file"
    [ "$calls" -ge 3 ]
}

retry 5 1 flaky
echo 0 > "$counter_file"
retry 2 1 flaky || echo "As expected, 2 attempts were not enough"
