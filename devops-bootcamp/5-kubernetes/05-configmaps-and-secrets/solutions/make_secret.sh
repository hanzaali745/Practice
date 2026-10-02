#!/usr/bin/env bash
# Lab 3 — create or update the demo-secret from environment variables (never from files in Git)
# Usage: DB_PASSWORD=... API_TOKEN=... ./make_secret.sh [namespace]
set -euo pipefail

ns="${1:-default}"
: "${DB_PASSWORD:?DB_PASSWORD must be set in the environment}"
: "${API_TOKEN:?API_TOKEN must be set in the environment}"

# --dry-run=client -o yaml | kubectl apply  → idempotent: creates the first time, updates afterwards
kubectl create secret generic demo-secret -n "$ns" \
    --from-literal=DB_PASSWORD="$DB_PASSWORD" \
    --from-literal=API_TOKEN="$API_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -

echo "describe shows sizes only, never values:"
kubectl describe secret demo-secret -n "$ns" | sed -n '/^Data/,$p'
