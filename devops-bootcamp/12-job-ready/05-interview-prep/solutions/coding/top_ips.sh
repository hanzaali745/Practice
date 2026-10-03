#!/usr/bin/env bash
# top_ips.sh [LOG] [N] — the same in a one-liner: the classic interview answer
#   awk '{print $1}' access.log | sort | uniq -c | sort -rn | head
set -euo pipefail
log=${1:-/dev/stdin}
n=${2:-10}
awk '{print $1}' "$log" | sort | uniq -c | sort -rn | head -n "$n"
