#!/usr/bin/env bash
# Lab 2 — show what the viewer ServiceAccount can and cannot do
set -euo pipefail

who="system:serviceaccount:dev:viewer"
for check in "list pods -n dev" "get pods/log -n dev" "delete pods -n dev" "list pods -n default" "list secrets -n dev" "create deployments -n dev"; do
    # shellcheck disable=SC2086  # $check is intentionally split into verb/resource/flags
    answer=$(kubectl auth can-i $check --as="$who" 2> /dev/null || true)
    printf '  %-28s %s\n' "$check" "$answer"
done
