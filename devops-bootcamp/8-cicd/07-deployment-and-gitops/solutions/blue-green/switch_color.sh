#!/usr/bin/env bash
# switch_color.sh blue|green — send ALL traffic to one color, but only if that color is fully ready
set -euo pipefail
color=${1:?usage: switch_color.sh blue|green}
[[ $color == blue || $color == green ]] || { echo "color must be blue or green" >&2; exit 2; }

kubectl rollout status "deployment/demo-$color" --timeout=120s
ready=$(kubectl get "deployment/demo-$color" -o jsonpath='{.status.readyReplicas}')
want=$(kubectl get "deployment/demo-$color" -o jsonpath='{.spec.replicas}')
[[ ${ready:-0} -eq $want ]] || { echo "demo-$color is not fully ready ($ready/$want) — not switching" >&2; exit 1; }

before=$(kubectl get service demo-bg -o jsonpath='{.spec.selector.color}')
kubectl patch service demo-bg -p "{\"spec\":{\"selector\":{\"app\":\"demo-bg\",\"color\":\"$color\"}}}"
echo "traffic: $before → $color   (roll back instantly with: $0 $before)"
