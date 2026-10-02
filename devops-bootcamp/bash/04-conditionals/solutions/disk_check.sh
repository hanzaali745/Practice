#!/usr/bin/env bash
# Lab 1 — disk check with Nagios-style exit codes (0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN)
# Usage: ./disk_check.sh [mount] [warn] [crit]
mount="${1:-/}"
warn="${2:-80}"
crit="${3:-90}"

if [[ ! -d $mount ]]; then
    echo "UNKNOWN - $mount is not a directory"
    exit 3
fi

usage=$(df --output=pcent "$mount" | tail -n 1 | tr -dc '0-9')

if (( usage >= crit )); then
    echo "CRITICAL - $mount at ${usage}% (crit ${crit}%)"
    exit 2
elif (( usage >= warn )); then
    echo "WARNING - $mount at ${usage}% (warn ${warn}%)"
    exit 1
else
    echo "OK - $mount at ${usage}%"
    exit 0
fi
