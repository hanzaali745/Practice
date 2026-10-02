#!/usr/bin/env bash
# Lab 4 — explain how a Service is wired up, and test it from inside the cluster
# Usage: ./svc_check.sh SERVICE [NAMESPACE]
set -euo pipefail

svc="${1:?Usage: $0 SERVICE [NAMESPACE]}"
ns="${2:-$(kubectl config view --minify -o jsonpath='{..namespace}')}"
ns="${ns:-default}"

kubectl get svc "$svc" -n "$ns" > /dev/null || exit 1
echo "== Service $ns/$svc"
kubectl get svc "$svc" -n "$ns" -o custom-columns='TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,PORTS:.spec.ports[*].port,TARGET:.spec.ports[*].targetPort'

# shellcheck disable=SC2016  # the $ belongs to the Go template, not the shell
selector=$(kubectl get svc "$svc" -n "$ns" -o go-template='{{range $k, $v := .spec.selector}}{{$k}}={{$v}},{{end}}')
selector="${selector%,}"
echo "selector: ${selector:-<none>}"

mapfile -t endpoints < <(kubectl get endpointslices -n "$ns" -l "kubernetes.io/service-name=$svc" \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}')
mapfile -t pods < <(kubectl get pods -n "$ns" -l "$selector" --field-selector=status.phase=Running -o name 2> /dev/null)

echo "endpoints (${#endpoints[@]}): ${endpoints[*]:-none}"
echo "running pods matching selector (${#pods[@]}): ${pods[*]:-none}"
if (( ${#endpoints[@]} == 0 )); then
    echo "⚠️  no endpoints — check the selector matches pod labels, and that pods are Ready" >&2
elif (( ${#endpoints[@]} != ${#pods[@]} )); then
    echo "⚠️  endpoint count differs from running pods — some pods are not Ready" >&2
fi

port=$(kubectl get svc "$svc" -n "$ns" -o jsonpath='{.spec.ports[0].port}')
echo "== in-cluster request to http://$svc.$ns:$port/"
kubectl run "svc-check-$RANDOM" -n "$ns" --rm -i --restart=Never --image=busybox:1.36 --quiet -- \
    wget -qO- -T 5 "http://$svc.$ns:$port/" || echo "request FAILED" >&2
