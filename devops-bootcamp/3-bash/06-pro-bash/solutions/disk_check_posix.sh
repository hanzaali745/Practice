#!/bin/sh
# Lab 3 — POSIX sh port of Module 04's disk_check.sh (runs in dash / Alpine ash / BusyBox)
# Usage: disk_check_posix.sh [mount] [warn] [crit]
# Exit codes: 0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN
set -eu

mount="${1:-/}"
warn="${2:-80}"
crit="${3:-90}"

if [ ! -d "$mount" ]; then
    echo "UNKNOWN - $mount is not a directory"
    exit 3
fi

# `df -P` = POSIX output format (works on BusyBox too); column 5 is "Use%"
usage=$(df -P "$mount" | awk 'NR == 2 { sub(/%/, "", $5); print $5 }')

if [ "$usage" -ge "$crit" ]; then
    echo "CRITICAL - $mount at ${usage}% (crit ${crit}%)"
    exit 2
elif [ "$usage" -ge "$warn" ]; then
    echo "WARNING - $mount at ${usage}% (warn ${warn}%)"
    exit 1
fi
echo "OK - $mount at ${usage}%"
