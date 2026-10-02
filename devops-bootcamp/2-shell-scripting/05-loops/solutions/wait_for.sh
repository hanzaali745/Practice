#!/bin/sh
# Lab 5 — wait until host:port accepts TCP connections
# Usage: sh wait_for.sh <host> <port> [timeout_seconds]
set -eu

host="${1:?Usage: $0 <host> <port> [timeout]}"
port="${2:?Usage: $0 <host> <port> [timeout]}"
timeout_s="${3:-30}"
elapsed=0

until nc -z -w1 "$host" "$port" 2> /dev/null; do
    if [ "$elapsed" -ge "$timeout_s" ]; then
        echo "Timed out after ${timeout_s}s waiting for $host:$port" >&2
        exit 1
    fi
    echo "Waiting for $host:$port... (${elapsed}s)"
    sleep 1
    elapsed=$((elapsed + 1))
done
echo "$host:$port is available after ${elapsed}s"
