#!/usr/bin/env bash
# install_stack.sh — Prometheus Operator + Prometheus + Alertmanager + Grafana + node-exporter + kube-state-metrics
# into the kind lab cluster from Phase 5, pinned to one chart version
set -euo pipefail
cd "$(dirname "$0")"
version=91.9.0

kubectl get nodes > /dev/null || { echo "no cluster — create your kind cluster first (Phase 5)" >&2; exit 1; }
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts > /dev/null
helm repo update prometheus-community > /dev/null
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    --version "$version" --namespace monitoring --create-namespace \
    --values values.yaml --wait --timeout 10m

echo
echo "Grafana:      kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80        (admin / bootcamp)"
echo "Prometheus:   kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090"
echo "Alertmanager: kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-alertmanager 9093"
