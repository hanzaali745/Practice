#!/usr/bin/env bash
# Lab 4 — copy the newest Redis backup off the cluster and verify it
set -euo pipefail

helper="backup-reader"
trap 'kubectl delete pod "$helper" --wait=false > /dev/null 2>&1 || true' EXIT

kubectl run "$helper" --image=redis:7-alpine --restart=Never \
    --overrides='{"spec":{"volumes":[{"name":"b","persistentVolumeClaim":{"claimName":"redis-backups"}}],"containers":[{"name":"r","image":"redis:7-alpine","command":["sleep","600"],"volumeMounts":[{"name":"b","mountPath":"/backup"}]}]}}' \
    > /dev/null
kubectl wait --for=condition=Ready "pod/$helper" --timeout=120s > /dev/null

newest=$(kubectl exec "$helper" -- sh -c 'ls -1t /backup/dump-*.rdb 2> /dev/null | head -n 1')
[[ -n $newest ]] || { echo "no backups found yet — has the CronJob run?" >&2; exit 1; }
echo "newest backup: $newest"

kubectl exec "$helper" -- redis-check-rdb "$newest" | tail -n 3
mkdir -p backups
kubectl cp "$helper:$newest" "backups/$(basename "$newest")" > /dev/null
echo "copied to backups/$(basename "$newest") ($(du -h "backups/$(basename "$newest")" | cut -f1))"
