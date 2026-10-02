#!/usr/bin/env bash
# Lab 5 — count log levels with an associative array
set -euo pipefail

log="${1:-$(dirname "$0")/../../../1-python/07-files-and-errors/data/app.log}"
declare -A count=()

while read -r _date _time level _rest; do
    [[ -n ${level:-} ]] || continue
    (( ++count[$level] ))
done < "$log"

for level in "${!count[@]}"; do
    printf "%-9s %d\n" "$level" "${count[$level]}"
done | sort -k2 -nr
