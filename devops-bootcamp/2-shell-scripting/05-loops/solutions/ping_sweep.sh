#!/bin/sh
# Lab 4 — check each host in a file is reachable
# Usage: sh ping_sweep.sh [hosts.txt]
hosts_file="${1:-$(dirname "$0")/../data/servers.txt}"
up=0
down=0

if ! command -v ping > /dev/null 2>&1; then
    echo "ping is not installed. Run: sudo apt install iputils-ping" >&2
    exit 1
fi

while IFS= read -r host; do
    case "$host" in
        ''|'#'*) continue ;;
    esac
    if ping -c1 -W1 "$host" > /dev/null 2>&1; then
        echo "UP   $host"
        up=$((up + 1))
    else
        echo "DOWN $host"
        down=$((down + 1))
    fi
done < "$hosts_file"

echo "Summary: $up up, $down down"
