#!/usr/bin/env bash
# Lab 4 — check each host in a file is reachable
set -uo pipefail

hosts_file="${1:-$(dirname "$0")/../data/servers.txt}"
up=0; down=0

is_up() {
    if command -v ping &>/dev/null; then
        ping -c1 -W1 "$1" &>/dev/null
    else
        getent hosts "$1" &>/dev/null   # fallback: at least resolves
    fi
}

while IFS= read -r host; do
    [[ -z $host || $host == \#* ]] && continue
    if is_up "$host"; then
        echo "UP   $host"; (( ++up ))
    else
        echo "DOWN $host"; (( ++down ))
    fi
done < "$hosts_file"

echo "Summary: $up up, $down down"
