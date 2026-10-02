#!/usr/bin/env bash
# Lab 1 — first-look diagnosis of every workload in a namespace
# Usage: ./diagnose.sh NAMESPACE
set -euo pipefail

ns="${1:?Usage: $0 NAMESPACE}"

echo "== Pods in $ns"
kubectl get pods -n "$ns" -o wide

echo
echo "== Pods that need attention"
kubectl get pods -n "$ns" --no-headers | while read -r name ready status restarts _; do
    want="${ready#*/}"; have="${ready%/*}"
    [[ $status == Running && $have == "$want" ]] && continue
    echo "--- $name  (status=$status ready=$ready restarts=$restarts)"
    kubectl get events -n "$ns" --field-selector "involvedObject.name=$name" \
        --sort-by=.lastTimestamp -o custom-columns=REASON:.reason,MESSAGE:.message --no-headers | tail -n 2 | sed 's/^/    event: /'
    if [[ $status == CrashLoopBackOff || $status == Error ]]; then
        kubectl logs -n "$ns" "$name" --previous --tail=3 2> /dev/null | sed 's/^/    log:   /' || true
    fi
done

echo
echo "== Services without endpoints"
for svc in $(kubectl get svc -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    count=$(kubectl get endpointslices -n "$ns" -l "kubernetes.io/service-name=$svc" \
        -o jsonpath='{range .items[*].endpoints[*]}x{end}' | wc -c)
    if (( count == 0 )); then
        echo "    $svc has NO endpoints — selector: $(kubectl get svc "$svc" -n "$ns" -o jsonpath='{.spec.selector}')"
    fi
done
