#!/bin/sh
# Lab 5 — security report from an nginx access log
# Usage: sh security_report.sh [access.log]
set -eu

log="${1:-$(dirname "$0")/../data/access.log}"
[ -r "$log" ] || { echo "Cannot read $log" >&2; exit 1; }

echo "== Brute-force suspects (>= 3 x 401) =="
awk '$9 == 401 {count[$1]++} END {for (ip in count) if (count[ip] >= 3) print "  " ip ": " count[ip] " failed logins"}' "$log"

echo "== Non-browser user agents =="
# The user agent is the 6th double-quote separated field
awk -F'"' '$6 !~ /Mozilla/ {print "  " $6}' "$log" | sort | uniq -c | sort -nr

echo "== Error rate =="
awk '{total++; if ($9 >= 400) errors++} END {printf "  %d/%d requests failed (%.1f%%)\n", errors, total, errors / total * 100}' "$log"
