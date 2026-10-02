#!/usr/bin/env bash
#
# deploy.sh — build, load, deploy and verify demo-app on the kind lab cluster; roll back on failure
# Usage: deploy.sh dev|prod VERSION
#   Example: deploy.sh dev 1.1.0
#
set -euo pipefail
cd "$(dirname "$0")"

env="${1:-}"; version="${2:-}"
[[ $env =~ ^(dev|prod)$ && -n $version ]] || { sed -n '3,5p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

ns="demo-$env"
host=$([[ $env == prod ]] && echo demo.localtest.me || echo demo-dev.localtest.me)
app_src="${APP_SRC:-../../../../4-docker/03-dockerfile/solutions/demo-app}"

log() { printf '%s [deploy] %s\n' "$(date +%T)" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

ctx=$(kubectl config current-context)
[[ $ctx == kind-lab ]] || die "current context is '$ctx' — this script only deploys to kind-lab"

log "building demo-app:$version"
docker build -q --build-arg VERSION="$version" -t "demo-app:$version" "$app_src" > /dev/null
kind load docker-image "demo-app:$version" --name lab > /dev/null

# Render the overlay with the new image tag WITHOUT editing files in Git (a temp overlay on top)
# (Kustomize only accepts RELATIVE paths, so the temp overlay lives inside this folder.)
tmp=$(mktemp -d ./.deploy.XXXXXX)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../overlays/$env
images:
  - name: demo-app
    newTag: "$version"
EOF

log "applying overlay $env (namespace $ns)"
kubectl apply -k "$tmp" > /dev/null
kubectl -n "$ns" rollout status statefulset/redis --timeout=120s > /dev/null

if ! kubectl -n "$ns" rollout status deployment/demo --timeout=120s; then
    log "❌ rollout failed — rolling back"
    kubectl -n "$ns" rollout undo deployment/demo
    kubectl -n "$ns" rollout status deployment/demo --timeout=120s
    exit 1
fi

log "smoke test http://$host/"
for _ in {1..20}; do
    body=$(curl -sf "http://$host/" || true)
    [[ $body == *"\"version\": \"$version\""* ]] && break
    sleep 2
done
[[ $body == *"\"version\": \"$version\""* ]] || die "smoke test failed: $body"
curl -sf "http://$host/visits" > /dev/null || die "/visits failed (Redis?)"
log "✅ demo-app $version is live on http://$host/"
