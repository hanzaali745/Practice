#!/bin/sh
# Lab 2 — create 20 log files, then report their line counts
set -eu

mkdir -p logs
for i in $(seq -w 1 20); do
    echo "app-$i.log created on $(date +%F)" > "logs/app-$i.log"
done

for file in logs/*.log; do
    [ -e "$file" ] || continue
    echo "$file: $(wc -l < "$file") line(s)"
done
