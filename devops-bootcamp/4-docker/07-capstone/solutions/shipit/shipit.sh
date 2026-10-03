#!/usr/bin/env bash
#
# shipit.sh — build, push, deploy, verify and roll back demo-app with Docker Compose
# Usage:
#   shipit.sh registry          start a private registry on localhost:5000
#   shipit.sh release [TAG]     build + push (TAG defaults to the git commit SHA)
#   shipit.sh deploy TAG        deploy TAG; auto-rollback to the previous good tag on failure
#   shipit.sh rollback          redeploy the previous good tag
#   shipit.sh status            show running services and tags
#   shipit.sh down              stop the stack (keeps volumes)
#
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"
export REGISTRY="${REGISTRY:-localhost:5000}"
export PROXY_PORT="${PROXY_PORT:-8080}"
STATE_DIR=".shipit"
CURRENT="$STATE_DIR/current"
PREVIOUS="$STATE_DIR/previous"
BASE_URL="http://localhost:$PROXY_PORT"

log() { printf '%s [shipit] %s\n' "$(date +%T)" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
usage() { sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

compose() { docker compose -f compose.yaml "$@"; }

cmd_registry() {
    if docker ps --format '{{.Names}}' | grep -qx registry; then
        log "registry already running"
    else
        docker run -d --name registry --restart unless-stopped -p 127.0.0.1:5000:5000 \
            -v shipit-registry:/var/lib/registry registry:2 > /dev/null
        log "registry started on $REGISTRY"
    fi
    until curl -sf "http://$REGISTRY/v2/" > /dev/null; do sleep 0.5; done
}

cmd_release() {
    local tag="${1:-$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"
    local image="$REGISTRY/demo-app:$tag"
    log "building $image"
    docker build -q --build-arg VERSION="$tag" --build-arg GIT_SHA="$tag" -t "$image" app > /dev/null
    docker push -q "$image" > /dev/null
    log "pushed $image"
    echo "$tag"
}

smoke_test() {
    local tag="$1" body
    body=$(curl -sf "$BASE_URL/") || return 1
    [[ $body == *"\"version\": \"$tag\""* ]] || { log "expected version $tag, got: $body"; return 1; }
    curl -sf "$BASE_URL/health" > /dev/null || return 1
    curl -sf "$BASE_URL/visits" > /dev/null || return 1
}

deploy_tag() {
    local tag="$1"
    docker manifest inspect --insecure "$REGISTRY/demo-app:$tag" > /dev/null 2>&1 \
        || docker image inspect "$REGISTRY/demo-app:$tag" > /dev/null 2>&1 \
        || die "image $REGISTRY/demo-app:$tag not found — run: shipit.sh release"
    log "deploying $tag"
    APP_TAG="$tag" compose up -d --wait --wait-timeout 60 > "$STATE_DIR/last-deploy.log" 2>&1 \
        && smoke_test "$tag"
}

cmd_deploy() {
    local tag="${1:?usage: shipit.sh deploy TAG}"
    mkdir -p "$STATE_DIR"
    local good=""
    [[ -f $CURRENT ]] && good=$(< "$CURRENT")

    if deploy_tag "$tag"; then
        [[ -n $good && $good != "$tag" ]] && echo "$good" > "$PREVIOUS"
        echo "$tag" > "$CURRENT"
        log "✅ $tag is live at $BASE_URL"
        return 0
    fi

    log "❌ deploy of $tag failed"
    if [[ -z $good ]]; then
        die "no previous good release to roll back to (see $STATE_DIR/last-deploy.log)"
    fi
    log "↩️  rolling back to $good"
    deploy_tag "$good" || die "ROLLBACK FAILED — manual intervention needed"
    log "✅ rolled back to $good"
    return 1
}

cmd_rollback() {
    [[ -f $PREVIOUS ]] || die "no previous release recorded"
    local prev current
    prev=$(< "$PREVIOUS")
    current=$(< "$CURRENT")
    deploy_tag "$prev" || die "rollback deploy failed"
    echo "$current" > "$PREVIOUS"
    echo "$prev" > "$CURRENT"
    log "✅ rolled back from $current to $prev"
}

cmd_status() {
    APP_TAG="$(cat "$CURRENT" 2> /dev/null || echo none)" compose ps --format 'table {{.Service}}\t{{.Status}}\t{{.Image}}'
    echo "current:  $(cat "$CURRENT" 2> /dev/null || echo -)"
    echo "previous: $(cat "$PREVIOUS" 2> /dev/null || echo -)"
}

cmd_down() {
    APP_TAG=none compose down > /dev/null 2>&1
    log "stack stopped (volume kept)"
}

case "${1:-}" in
    registry) cmd_registry ;;
    release)  shift; cmd_release "$@" ;;
    deploy)   shift; cmd_deploy "$@" ;;
    rollback) cmd_rollback ;;
    status)   cmd_status ;;
    down)     cmd_down ;;
    *)        usage ;;
esac
