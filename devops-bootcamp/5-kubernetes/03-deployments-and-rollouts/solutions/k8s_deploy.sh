#!/usr/bin/env bash
#
# k8s_deploy.sh — roll out a new demo-app tag; undo automatically if it doesn't become ready
# Usage: k8s_deploy.sh TAG [deployment] [container]
#
set -euo pipefail

tag="${1:?Usage: $0 TAG [deployment] [container]}"
deploy="${2:-demo}"
container="${3:-app}"
timeout="${ROLLOUT_TIMEOUT:-90s}"

ctx=$(kubectl config current-context)
echo "context: $ctx"

# Pause → make ALL changes → resume, so they become ONE revision.
# (Two separate changes = two revisions, and `rollout undo` would only revert the last one!)
kubectl rollout pause "deployment/$deploy" > /dev/null
kubectl set image "deployment/$deploy" "$container=demo-app:$tag" > /dev/null
kubectl set env "deployment/$deploy" "APP_VERSION=$tag" > /dev/null
kubectl annotate "deployment/$deploy" kubernetes.io/change-cause="deploy $tag via k8s_deploy.sh" --overwrite > /dev/null
kubectl rollout resume "deployment/$deploy" > /dev/null

if kubectl rollout status "deployment/$deploy" --timeout="$timeout"; then
    echo "✅ $deploy is now running $tag"
    exit 0
fi

echo "❌ rollout of $tag did not complete within $timeout — rolling back" >&2
kubectl rollout undo "deployment/$deploy"
kubectl rollout status "deployment/$deploy" --timeout="$timeout"
echo "↩️  rolled back; current image: $(kubectl get "deployment/$deploy" -o jsonpath="{.spec.template.spec.containers[?(@.name=='$container')].image}")" >&2
exit 1
