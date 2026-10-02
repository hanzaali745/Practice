#!/usr/bin/env bash
# Lab 4 — count HIGH+CRITICAL vulnerabilities per image with Trivy
# Usage: ./scan_compare.sh [image...]
set -euo pipefail

images=("$@")
(( ${#images[@]} > 0 )) || images=(python:3.12 python:3.12-slim demo-app:secure)
command -v jq > /dev/null || { echo "jq is required" >&2; exit 1; }

printf '%-25s %8s %8s\n' IMAGE HIGH CRITICAL
for img in "${images[@]}"; do
    json=$(docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache \
        aquasec/trivy:0.56.2 image --quiet --format json --severity HIGH,CRITICAL "$img")
    high=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' <<< "$json")
    crit=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' <<< "$json")
    printf '%-25s %8s %8s\n' "$img" "$high" "$crit"
done
