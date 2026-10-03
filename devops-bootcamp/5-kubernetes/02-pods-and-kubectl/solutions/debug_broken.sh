#!/usr/bin/env bash
# Lab 2 — apply the broken pods, then print the clue for each one
set -euo pipefail
cd "$(dirname "$0")"

kubectl apply -f broken-pods.yaml
echo "waiting 30s for things to go wrong..."
sleep 30

kubectl get pods -l lab=broken
for pod in broken-image broken-crash broken-pending; do
    echo
    echo "== $pod"
    echo "status: $(kubectl get pod "$pod" -o jsonpath='{.status.phase}') / $(kubectl get pod "$pod" -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}')"
    echo "last events:"
    kubectl get events --field-selector "involvedObject.name=$pod" --sort-by=.lastTimestamp -o custom-columns=REASON:.reason,MESSAGE:.message --no-headers | tail -2 | sed 's/^/  /'
done
echo
echo "== crash logs (--previous):"
kubectl logs broken-crash --previous 2> /dev/null || kubectl logs broken-crash

kubectl delete -f broken-pods.yaml --wait=false
