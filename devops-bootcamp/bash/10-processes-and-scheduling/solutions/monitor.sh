#!/usr/bin/env bash
# Lab 4 — tiny monitor suitable for cron:
#   * * * * * /full/path/to/monitor.sh >> /tmp/monitor.log 2>&1
set -euo pipefail
PATH=/usr/local/bin:/usr/bin:/bin   # cron has a minimal PATH — be explicit

load=$(cut -d' ' -f1 /proc/loadavg)
mem=$(free | awk '/^Mem:/ { printf "%.0f", $3 / $2 * 100 }')
disk=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')

echo "$(date '+%F %T') load=$load mem=${mem}% disk=${disk}%"
