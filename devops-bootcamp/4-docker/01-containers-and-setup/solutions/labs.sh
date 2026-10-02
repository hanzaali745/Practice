#!/usr/bin/env bash
# Docker Module 01 — Labs 1, 2 and 4 as commands (type them yourself to learn them).
set -euo pipefail

echo "== Lab 1: three different 'operating systems' =="
for img in alpine:3.20 ubuntu:24.04 python:3.12-slim; do
    printf '%-18s %s\n' "$img" "$(docker run --rm "$img" sh -c '. /etc/os-release; echo "$PRETTY_NAME"')"
done
docker run --rm python:3.12-slim python3 -c "print(2**10)"
docker images --format 'table {{.Repository}}:{{.Tag}}\t{{.Size}}' | grep -E 'alpine|ubuntu|python' || true

echo "== Lab 2: changes inside a container are lost when it is removed =="
docker rm -f web > /dev/null 2>&1 || true
docker run -d --name web -p 8080:80 nginx:1.27-alpine > /dev/null
sleep 1
docker exec web sh -c 'echo "Hello DevOps" > /usr/share/nginx/html/index.html'
echo "after edit:     $(curl -s localhost:8080)"
docker rm -f web > /dev/null
docker run -d --name web -p 8080:80 nginx:1.27-alpine > /dev/null
sleep 1
echo "new container:  $(curl -s localhost:8080 | grep -o '<title>.*</title>')   <- the edit is gone"
docker rm -f web > /dev/null

echo "== Lab 4: three web servers =="
for i in 1 2 3; do
    docker run -d --name "web$i" -p "808$i:80" nginx:1.27-alpine > /dev/null
done
docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}' --filter name=web
docker stop web2 > /dev/null
echo "-- docker ps (running only):"; docker ps --format '{{.Names}}' --filter name=web
echo "-- docker ps -a (all):";      docker ps -a --format '{{.Names}} {{.Status}}' --filter name=web
docker rm -f web1 web2 web3 > /dev/null
echo "cleaned up"
