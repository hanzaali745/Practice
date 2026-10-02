#!/usr/bin/env bash
# Lab 3 — read the inventory CSV and summarise it
set -euo pipefail

csv="${1:-$(dirname "$0")/../data/inventory.csv}"
prod=0; staging=0; dev=0

printf "%-8s %-12s %-8s %s\n" "NAME" "IP" "ENV" "ROLE"
while IFS=, read -r name ip env role; do
    [[ -z $name || $name == \#* || $name == "name" ]] && continue
    printf "%-8s %-12s %-8s %s\n" "$name" "$ip" "$env" "$role"
    case "$env" in
        prod)    (( ++prod )) ;;
        staging) (( ++staging )) ;;
        dev)     (( ++dev )) ;;
    esac
done < "$csv"

echo
echo "prod=$prod staging=$staging dev=$dev"
