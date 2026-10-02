#!/bin/sh
# Lab 1 — disk check with Nagios exit codes (0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN)
# Usage: sh disk_check.sh [mount] [warn] [crit]
mount="${1:-/}"
warn="${2:-80}"
crit="${3:-90}"

if [ ! -d "$mount" ]; then
    echo "UNKNOWN - $mount is not a directory"
    exit 3
fi

# df -P = portable output; column 5 is "Use%" — remove the % sign
usage=$(df -P "$mount" | awk 'NR == 2 { sub("%", "", $5); print $5 }')

if [ "$usage" -ge "$crit" ]; then
    echo "CRITICAL - $mount at ${usage}% (crit ${crit}%)"
    exit 2
elif [ "$usage" -ge "$warn" ]; then
    echo "WARNING - $mount at ${usage}% (warn ${warn}%)"
    exit 1
else
    echo "OK - $mount at ${usage}%"
    exit 0
fi
