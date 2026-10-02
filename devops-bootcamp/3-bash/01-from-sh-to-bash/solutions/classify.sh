#!/usr/bin/env bash
# Lab 2 — classify hostnames with [[ ]] patterns and =~
# Usage: ./classify.sh web-07 db-01 redis-3 printer
if (( $# == 0 )); then
    echo "Usage: $0 <hostname>..." >&2
    exit 2
fi

for host in "$@"; do
    if [[ $host == web-* ]]; then
        kind="web"
    elif [[ $host == db-* || $host == postgres* ]]; then
        kind="database"
    elif [[ $host == cache-* || $host == redis* ]]; then
        kind="cache"
    else
        kind="unknown"
    fi

    if [[ $host =~ -([0-9]+)$ ]]; then
        number="${BASH_REMATCH[1]}"
    else
        number="-"
    fi
    printf '%-10s %-9s number=%s\n' "$host" "$kind" "$number"
done
