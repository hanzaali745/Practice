#!/usr/bin/env bash
# Lab 3 — list every repository and tag in a registry (Docker Registry HTTP API v2)
# Usage: ./registry_report.sh [http://localhost:5000]
set -euo pipefail

url="${1:-http://localhost:5000}"
command -v jq > /dev/null || { echo "jq is required: sudo apt install jq" >&2; exit 1; }

catalog=$(curl -sf "$url/v2/_catalog") || { echo "cannot reach registry at $url" >&2; exit 1; }
mapfile -t repos < <(jq -r '.repositories[]?' <<< "$catalog")

if (( ${#repos[@]} == 0 )); then
    echo "registry is empty"
    exit 0
fi

for repo in "${repos[@]}"; do
    tags=$(curl -sf "$url/v2/$repo/tags/list" | jq -r '(.tags // []) | sort | join(", ")')
    printf '%-30s %s\n' "$repo" "${tags:-<no tags>}"
done
