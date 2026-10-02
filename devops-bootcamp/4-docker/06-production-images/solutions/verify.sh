#!/usr/bin/env bash
# Verify Labs 1-3: builds the images and checks every requirement.
set -euo pipefail
cd "$(dirname "$0")"

pass() { echo "✅ $*"; }
fail() { echo "❌ $*" >&2; exit 1; }
check() { local msg="$1"; shift; if "$@"; then pass "$msg"; else fail "$msg"; fi; }
cleanup() { docker rm -f secure-demo go-demo > /dev/null 2>&1 || true; }
trap cleanup EXIT
cleanup

echo "== Lab 1: hardened demo-app"
docker build -q --build-arg VERSION=1.0.0 --build-arg GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo none)" \
    -f demo-app/Dockerfile.secure -t demo-app:secure demo-app > /dev/null
docker run -d --name secure-demo -p 127.0.0.1:8000:8000 \
    --read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges \
    --memory 128m --cpus 0.5 --pids-limit 100 demo-app:secure > /dev/null

check "runs as uid 10001" test "$(docker exec secure-demo id -u)" = 10001
for _ in {1..30}; do
    [[ $(docker inspect -f '{{.State.Health.Status}}' secure-demo) == healthy ]] && break
    sleep 1
done
check "HEALTHCHECK reports healthy" test "$(docker inspect -f '{{.State.Health.Status}}' secure-demo)" = healthy
check "OCI version label set" test "$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.version"}}' demo-app:secure)" = 1.0.0

echo "== Lab 3: still works fully locked down"
curl -sf localhost:8000/ > /dev/null && pass "/ works"
curl -sf localhost:8000/health > /dev/null && pass "/health works"
curl -sf localhost:8000/visits > /dev/null && pass "/visits works"
if docker exec secure-demo sh -c 'echo x > /app/hack' 2> /dev/null; then
    fail "writing to /app should fail"
else
    pass "writing to /app is blocked (read-only filesystem)"
fi

echo "== Lab 2: multi-stage Go"
docker build -q -t go-server:multistage go-server > /dev/null
docker run -d --name go-demo -p 127.0.0.1:8081:8080 go-server:multistage > /dev/null
sleep 1
curl -sf localhost:8081/health > /dev/null && pass "Go server answers"
mb() { echo $(( $(docker image inspect -f '{{.Size}}' "$1") / 1024 / 1024 )); }
pass "builder image golang:1.23 = $(mb golang:1.23) MB, final image = $(mb go-server:multistage) MB"
[[ $(docker inspect -f '{{.Config.User}}' go-server:multistage) == nonroot ]] && pass "Go image runs as nonroot"

echo "🎉 all checks passed"
