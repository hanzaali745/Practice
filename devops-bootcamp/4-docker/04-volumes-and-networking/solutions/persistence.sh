#!/usr/bin/env bash
# Lab 1 — data in a named volume survives the container; data in the container layer does not
set -euo pipefail
trap 'docker rm -f r1 r2 r3 r4 > /dev/null 2>&1 || true' EXIT

wait_redis() { until docker exec "$1" redis-cli ping 2> /dev/null | grep -q PONG; do sleep 0.3; done; }

echo "== with a named volume"
docker run -d --name r1 -v lab-redis:/data redis:7-alpine redis-server --appendonly yes > /dev/null
wait_redis r1
docker exec r1 redis-cli SET greeting "hello volumes" > /dev/null
docker rm -f r1 > /dev/null
docker run -d --name r2 -v lab-redis:/data redis:7-alpine redis-server --appendonly yes > /dev/null
wait_redis r2
echo "  after replacing the container: $(docker exec r2 redis-cli GET greeting)"

echo "== without a volume"
docker run -d --name r3 redis:7-alpine redis-server --appendonly yes > /dev/null
wait_redis r3
docker exec r3 redis-cli SET greeting "lost soon" > /dev/null
docker rm -f r3 > /dev/null
docker run -d --name r4 redis:7-alpine redis-server --appendonly yes > /dev/null
wait_redis r4
echo "  after replacing the container: '$(docker exec r4 redis-cli GET greeting)' (empty = lost)"
# keep the volume for Lab 3; remove later with: docker volume rm lab-redis
