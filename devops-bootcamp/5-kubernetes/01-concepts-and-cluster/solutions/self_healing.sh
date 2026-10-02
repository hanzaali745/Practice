#!/usr/bin/env bash
# Lab 3 — watch Kubernetes replace deleted pods
set -euo pipefail

kubectl create deployment hello --image=nginx:1.27-alpine --replicas=3 --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout status deployment/hello --timeout=120s
echo "== pods before:"
kubectl get pods -l app=hello -o wide

kubectl delete pods -l app=hello --wait=false
echo "== right after deleting all of them:"
kubectl get pods -l app=hello
kubectl rollout status deployment/hello --timeout=120s
echo "== a moment later — 3 NEW pods (new names, new ages):"
kubectl get pods -l app=hello -o wide

kubectl delete deployment hello
