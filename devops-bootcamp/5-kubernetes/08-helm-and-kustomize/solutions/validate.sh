#!/usr/bin/env bash
# Render every Kustomize overlay and the Helm chart, and validate the output against
# the Kubernetes API schemas (needs kubectl, helm, kubeconform).
set -euo pipefail
cd "$(dirname "$0")"

K8S_VERSION="${K8S_VERSION:-1.31.0}"
validate() { kubeconform -strict -summary -kubernetes-version "$K8S_VERSION" -; }

for overlay in kustomize/overlays/*/; do
    echo "== kustomize ${overlay}"
    kubectl kustomize "$overlay" | validate
done

echo "== helm lint"
helm lint demo-app-chart -f demo-app-chart/values-prod.yaml --quiet
for values in "" "-f demo-app-chart/values-prod.yaml"; do
    echo "== helm template ${values:-(defaults)}"
    # shellcheck disable=SC2086  # $values is intentionally split into flag + file
    helm template demo demo-app-chart $values | validate
done
echo "🎉 all rendered manifests are valid"
