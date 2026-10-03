#!/usr/bin/env bash
# Render both overlays and validate them against the Kubernetes API schemas.
set -euo pipefail
cd "$(dirname "$0")"

for env in dev prod; do
    echo "== $env"
    kubectl kustomize "overlays/$env" | kubeconform -strict -summary -kubernetes-version "${K8S_VERSION:-1.31.0}" -
done
