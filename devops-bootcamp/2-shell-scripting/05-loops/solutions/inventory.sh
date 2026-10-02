#!/bin/sh
# Lab 3 — read the inventory CSV and summarise it
# Usage: sh inventory.sh [file.csv]
set -eu

csv="${1:-$(dirname "$0")/../data/inventory.csv}"
prod=0
staging=0
dev=0

printf '%-8s %-12s %-8s %s\n' "NAME" "IP" "ENV" "ROLE"
while IFS=, read -r name ip env role; do
    case "$name" in
        ''|'#'*|name) continue ;;
    esac
    printf '%-8s %-12s %-8s %s\n' "$name" "$ip" "$env" "$role"
    case "$env" in
        prod)    prod=$((prod + 1)) ;;
        staging) staging=$((staging + 1)) ;;
        dev)     dev=$((dev + 1)) ;;
    esac
done < "$csv"

echo
echo "prod=$prod staging=$staging dev=$dev"
