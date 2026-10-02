#!/usr/bin/env bash
# Lab 4 — disk usage calculator
# Usage: ./diskcalc.sh <used_gb> <total_gb>
set -euo pipefail

used="${1:?Usage: $0 <used_gb> <total_gb>}"
total="${2:?Usage: $0 <used_gb> <total_gb>}"

echo "Used (integer): $(( used * 100 / total ))%"
echo "Used (precise): $(awk -v u="$used" -v t="$total" 'BEGIN { printf "%.2f", u / t * 100 }')%"
echo "Free:           $(( total - used )) GB"
