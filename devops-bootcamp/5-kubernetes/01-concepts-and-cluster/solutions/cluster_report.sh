#!/usr/bin/env bash
# Lab 4 — quick, safe overview of the current cluster
set -euo pipefail

ctx=$(kubectl config current-context)
if [[ $ctx != kind-* ]]; then
    echo "Refusing to run: current context is '$ctx' (expected a kind-* lab cluster)" >&2
    exit 1
fi
echo "Context: $ctx"

echo
echo "== Nodes"
kubectl get nodes -o custom-columns='NAME:.metadata.name,ROLE:.metadata.labels.node-role\.kubernetes\.io/control-plane,VERSION:.status.nodeInfo.kubeletVersion,READY:.status.conditions[?(@.type=="Ready")].status'

echo
echo "== Pods per namespace"
kubectl get pods -A --no-headers | awk '{count[$1]++} END {for (ns in count) printf "  %-20s %d\n", ns, count[ns]}' | sort

echo
echo "== Pods that are NOT Running/Completed"
problems=$(kubectl get pods -A --no-headers | awk '$4 != "Running" && $4 != "Completed"')
if [[ -z $problems ]]; then
    echo "  none 🎉"
else
    echo "$problems"
    exit 1
fi
