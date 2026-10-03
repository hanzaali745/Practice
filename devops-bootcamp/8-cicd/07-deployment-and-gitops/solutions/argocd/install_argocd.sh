#!/usr/bin/env bash
# install_argocd.sh — Argo CD in your kind lab cluster (from Phase 5), pinned to one version
set -euo pipefail
version=v3.5.3

kubectl get nodes > /dev/null || { echo "no cluster — start your kind cluster first (Phase 5, Module 01)" >&2; exit 1; }
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
    -f "https://raw.githubusercontent.com/argoproj/argo-cd/${version}/manifests/install.yaml"
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo
echo "UI:        kubectl -n argocd port-forward svc/argocd-server 8443:443   →  https://localhost:8443"
echo "User:      admin"
echo "Password:  $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
