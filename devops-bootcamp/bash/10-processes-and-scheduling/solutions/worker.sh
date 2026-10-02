#!/usr/bin/env bash
# Lab 3 — long-running worker with graceful shutdown and config reload
# Run:   ./worker.sh &
# Test:  kill -HUP "$(cat /tmp/worker.pid)"   → reload config
#        kill -TERM "$(cat /tmp/worker.pid)"  → graceful stop
set -euo pipefail

PID_FILE="${PID_FILE:-/tmp/worker.pid}"
CONFIG_FILE="${CONFIG_FILE:-/tmp/worker.conf}"
running=true
interval=1

load_config() {
    if [[ -f $CONFIG_FILE ]]; then
        interval=$(awk -F= '$1 == "interval" {print $2}' "$CONFIG_FILE")
        interval="${interval:-1}"
    fi
    echo "[worker] config loaded: interval=${interval}s"
}

trap 'echo "[worker] stop requested, finishing current iteration"; running=false' TERM INT
trap 'load_config' HUP
trap 'rm -f "$PID_FILE"; echo "[worker] exited cleanly"' EXIT

echo $$ > "$PID_FILE"
load_config

iteration=0
while $running; do
    iteration=$(( iteration + 1 ))
    echo "[worker] iteration $iteration"
    # `wait` lets traps fire immediately instead of after sleep. A signal interrupts
    # `wait` with status >128, so `|| true` stops `set -e` from killing the worker.
    sleep "$interval" & wait $! || true
done
