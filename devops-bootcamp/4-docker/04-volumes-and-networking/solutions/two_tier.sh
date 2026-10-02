#!/usr/bin/env bash
#
# two_tier.sh — run demo-app + Redis by hand on a private network
# Usage: two_tier.sh up|down|status
#   Needs the demo-app:1.0.0 image (Docker Module 03, Lab 2).
#
set -euo pipefail

NET=appnet
VOL=two-tier-redis
APP_IMAGE="${APP_IMAGE:-demo-app:1.0.0}"

up() {
    docker network inspect "$NET" > /dev/null 2>&1 || docker network create "$NET" > /dev/null
    docker rm -f redis demo > /dev/null 2>&1 || true
    docker run -d --name redis --network "$NET" -v "$VOL":/data \
        redis:7-alpine redis-server --appendonly yes > /dev/null
    docker run -d --name demo --network "$NET" -p 127.0.0.1:8000:8000 \
        -e REDIS_HOST=redis "$APP_IMAGE" > /dev/null
    for _ in {1..30}; do
        curl -sf localhost:8000/health > /dev/null && { echo "up: http://localhost:8000"; return; }
        sleep 0.5
    done
    echo "demo-app did not become healthy" >&2
    docker logs demo >&2
    exit 1
}

down() {
    docker rm -f demo redis > /dev/null 2>&1 || true
    docker network rm "$NET" > /dev/null 2>&1 || true
    echo "down (volume $VOL kept)"
}

status() {
    docker ps --filter name='^(demo|redis)$' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    curl -s localhost:8000/visits || echo "demo-app not reachable"
}

case "${1:-}" in
    up) up ;;
    down) down ;;
    status) status ;;
    *) sed -n '3,4p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2 ;;
esac
