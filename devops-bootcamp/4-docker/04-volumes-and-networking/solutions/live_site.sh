#!/usr/bin/env bash
# Lab 2 — live-edited website through a read-only bind mount
set -euo pipefail
cd "$(dirname "$0")"
trap 'docker rm -f site > /dev/null 2>&1 || true; rm -rf site-demo' EXIT

mkdir -p site-demo
echo "<h1>Version 1</h1>" > site-demo/index.html
docker run -d --name site -p 127.0.0.1:8080:80 -v "$PWD/site-demo":/usr/share/nginx/html:ro nginx:1.27-alpine > /dev/null
until curl -sf localhost:8080 > /dev/null; do sleep 0.3; done
echo "before edit: $(curl -s localhost:8080)"
echo "<h1>Version 2 — edited on the host</h1>" > site-demo/index.html
echo "after edit:  $(curl -s localhost:8080)"

echo "trying to write from inside the container:"
docker exec site sh -c 'echo hacked > /usr/share/nginx/html/index.html' 2>&1 | sed 's/^/  /' || true
echo "→ refused: the mount is read-only (:ro), so the container can't change your files"
