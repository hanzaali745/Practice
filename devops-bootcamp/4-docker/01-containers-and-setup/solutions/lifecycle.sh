#!/usr/bin/env bash
# Lab 3 — container lifecycle drill
# Usage: ./lifecycle.sh [host_port]
set -euo pipefail

name="drill"
port="${1:-8090}"
trap 'docker rm -f "$name" > /dev/null 2>&1 || true' EXIT

docker run -d --name "$name" -p "$port:80" nginx:1.27-alpine > /dev/null
echo "started $name"

for attempt in {1..20}; do
    if curl -sf "localhost:$port" > /dev/null; then
        echo "responding after $attempt attempt(s)"
        break
    fi
    (( attempt == 20 )) && { echo "never became ready" >&2; exit 1; }
    sleep 0.5
done

echo "IP address: $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$name")"
docker stop "$name" > /dev/null
echo "after stop:  $(docker inspect -f '{{.State.Status}}' "$name")"
docker start "$name" > /dev/null
echo "after start: $(docker inspect -f '{{.State.Status}}' "$name")"
docker rm -f "$name" > /dev/null
echo "removed — exists now? $(docker ps -a --filter "name=^${name}$" --format '{{.Names}}' | grep -c . || true)"
