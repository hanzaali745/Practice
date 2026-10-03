#!/usr/bin/env bash
# Lab 2 — run a private registry, push, delete local copies, pull back
set -euo pipefail

REG="localhost:5000"

if ! docker ps --format '{{.Names}}' | grep -qx registry; then
    docker run -d --name registry -p 5000:5000 -v registry-data:/var/lib/registry registry:2 > /dev/null
    echo "registry started"
fi
until curl -sf "http://$REG/v2/" > /dev/null; do sleep 0.5; done

docker pull -q alpine:3.20 > /dev/null
for tag in 3.20 stable; do
    docker tag alpine:3.20 "$REG/lab/alpine:$tag"
    docker push -q "$REG/lab/alpine:$tag" > /dev/null
    echo "pushed $REG/lab/alpine:$tag"
done

echo "catalog: $(curl -s "http://$REG/v2/_catalog")"
echo "tags:    $(curl -s "http://$REG/v2/lab/alpine/tags/list")"

docker rmi "$REG/lab/alpine:3.20" "$REG/lab/alpine:stable" > /dev/null
docker pull -q "$REG/lab/alpine:stable" > /dev/null
docker run --rm "$REG/lab/alpine:stable" echo pulled-from-my-registry
# Clean up when you're done:  docker rm -f registry && docker volume rm registry-data
