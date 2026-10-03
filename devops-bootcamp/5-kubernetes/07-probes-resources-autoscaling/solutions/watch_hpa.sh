#!/usr/bin/env bash
# Lab 3 — log HPA status every 15 seconds (Ctrl+C to stop)
set -euo pipefail

hpa="${1:-demo}"
printf '%-9s %-12s %-9s %s\n' TIME TARGET REPLICAS "CPU (current/target)"
while true; do
    current=$(kubectl get hpa "$hpa" -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2> /dev/null || true)
    target=$(kubectl get hpa "$hpa" -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')
    replicas=$(kubectl get hpa "$hpa" -o jsonpath='{.status.currentReplicas}')
    printf '%-9s %-12s %-9s %s%%/%s%%\n' "$(date +%T)" "deploy/demo" "${replicas:-?}" "${current:-?}" "$target"
    sleep 15
done
