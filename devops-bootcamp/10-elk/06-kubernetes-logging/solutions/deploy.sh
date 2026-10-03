#!/usr/bin/env bash
# deploy.sh ES_API_KEY — install Fluent Bit into the current cluster (kind lab cluster from Phase 5)
#   The API key: Module 05, step 6 (create_doc-only on logs-*). Elasticsearch must be reachable from the cluster.
set -euo pipefail
cd "$(dirname "$0")"
key=${1:?usage: deploy.sh ES_API_KEY}
kubectl apply -f fluent-bit-daemonset.yaml
kubectl -n logging create configmap fluent-bit-config --from-file=fluent-bit.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl -n logging create secret generic elasticsearch-shipper --from-literal=api-key="$key" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n logging rollout restart daemonset/fluent-bit
kubectl -n logging rollout status daemonset/fluent-bit --timeout=120s
kubectl -n logging get pods -o wide
