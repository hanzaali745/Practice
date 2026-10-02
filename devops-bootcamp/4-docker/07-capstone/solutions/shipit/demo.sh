#!/usr/bin/env bash
# Walk through a full release cycle, including an automatic rollback of a broken release.
set -euo pipefail
cd "$(dirname "$0")"

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

step "1. private registry"
./shipit.sh registry

step "2. release + deploy v1"
./shipit.sh release v1 > /dev/null
./shipit.sh deploy v1
curl -s localhost:8080/visits; curl -s localhost:8080/visits

step "3. release + deploy v2"
./shipit.sh release v2 > /dev/null
./shipit.sh deploy v2
curl -s localhost:8080/

step "4. a BROKEN release v3 (healthcheck fails) → automatic rollback"
docker build -q --build-arg BASE=localhost:5000/demo-app:v2 -t localhost:5000/demo-app:v3 broken > /dev/null
docker push -q localhost:5000/demo-app:v3 > /dev/null
if ./shipit.sh deploy v3; then echo "unexpected: v3 should have failed"; exit 1; fi
curl -s localhost:8080/

step "5. status — still v2, and the visit count survived every deploy"
./shipit.sh status
curl -s localhost:8080/visits

step "6. manual rollback to v1"
./shipit.sh rollback
curl -s localhost:8080/

step "clean up"
./shipit.sh down
docker rm -f registry > /dev/null
docker volume rm shipit_redisdata shipit-registry > /dev/null
rm -rf .shipit
echo "done"
