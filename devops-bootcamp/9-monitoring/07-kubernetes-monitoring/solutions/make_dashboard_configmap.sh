#!/usr/bin/env bash
# make_dashboard_configmap.sh — wrap the Module 05 dashboard JSON in a labelled ConfigMap for Grafana's sidecar
set -euo pipefail
cd "$(dirname "$0")"
kubectl create configmap demo-app-dashboard --namespace demo \
    --from-file=demo-app-red.json=../../05-grafana/solutions/grafana/dashboards/demo-app-red.json \
    --dry-run=client -o yaml \
  | kubectl label --local -f - grafana_dashboard=1 -o yaml > dashboard-configmap.yaml
echo "dashboard-configmap.yaml written"
