#!/bin/sh
# Lab 4 — disk usage calculator
# Usage: sh diskcalc.sh <used_gb> <total_gb>
set -eu

used="${1:?Usage: $0 <used_gb> <total_gb>}"
total="${2:?Usage: $0 <used_gb> <total_gb>}"

echo "Used (whole): $((used * 100 / total))%"
echo "Used (exact): $(awk -v u="$used" -v t="$total" 'BEGIN { printf "%.2f", u / t * 100 }')%"
echo "Free:         $((total - used)) GB"
