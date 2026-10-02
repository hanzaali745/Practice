#!/usr/bin/env bash
# Lab 2 — create 20 log files, then report their line counts
set -euo pipefail

mkdir -p logs
for i in {01..20}; do
    echo "app-$i.log created on $(date +%F)" > "logs/app-$i.log"
done

for file in logs/*.log; do
    [[ -e $file ]] || continue
    echo "$file: $(wc -l < "$file") line(s)"
done
