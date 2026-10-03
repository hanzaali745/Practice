#!/usr/bin/env bash
# chaos.sh — break things on purpose and PROVE the alerts fire, route and resolve (takes ~10 minutes)
#   1. Redis down          → RedisDown (critical) → pager + chat
#   2. 30% errors          → DemoAppHighErrorRate (warning) → chat
#   3. silence it with amtool → no more notifications for it
#   4. everything fixed    → resolved notifications
set -euo pipefail
cd "$(dirname "$0")"
AM=http://localhost:9093
step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

alert_state() {                      # alert_state NAME → firing | none
    curl -fsS "$AM/api/v2/alerts?active=true&silenced=false&inhibited=false" | python3 -c "
import json, sys
names = {a['labels']['alertname'] for a in json.load(sys.stdin)}
print('firing' if '$1' in names else 'none')"
}

wait_for() {                         # wait_for NAME STATE TIMEOUT_SECONDS
    local name=$1 want=$2 timeout=$3 waited=0
    while [[ $(alert_state "$name") != "$want" ]]; do
        (( waited >= timeout )) && { echo "❌ $name did not become '$want' within ${timeout}s"; exit 1; }
        sleep 10; waited=$((waited + 10))
    done
    echo "✅ $name is $want (after ~${waited}s)"
}

notified() {                         # notified CHANNEL STATUS ALERT → did the receiver get it?
    docker compose exec -T receiver cat /data/notifications.jsonl 2>/dev/null | python3 -c "
import json, sys
ok = any(n['channel'] == '$1' and n['status'] == '$2' and '$3' in n['alerts'] for n in map(json.loads, sys.stdin))
print('✅' if ok else '❌', 'receiver got $2 $3 on #$1')
sys.exit(0 if ok else 1)"
}

step "Start the stack (1% errors — healthy)"
docker compose up -d --build --quiet-pull > /dev/null 2>&1
sleep 60

step "1. Stop Redis"
docker compose stop redis > /dev/null 2>&1
wait_for RedisDown firing 180
sleep 20; notified pager firing RedisDown; notified chat firing RedisDown

step "2. Raise the error rate to 30%"
ERROR_FRACTION=0.3 docker compose up -d load > /dev/null 2>&1
wait_for DemoAppHighErrorRate firing 360
sleep 20; notified chat firing DemoAppHighErrorRate

step "3. Silence DemoAppHighErrorRate for 1 hour (we're working on it)"
docker compose exec -T alertmanager amtool silence add alertname=DemoAppHighErrorRate \
    --alertmanager.url=http://localhost:9093 --duration=1h --author=chaos.sh --comment="known: chaos test" > /dev/null
wait_for DemoAppHighErrorRate none 60
docker compose exec -T alertmanager amtool silence query --alertmanager.url=http://localhost:9093

step "4. Fix everything"
docker compose start redis > /dev/null 2>&1
ERROR_FRACTION=0.01 docker compose up -d load > /dev/null 2>&1
wait_for RedisDown none 240
sleep 90; notified pager resolved RedisDown

step "What the receiver saw"
docker compose logs receiver --no-log-prefix | tail -20
echo; echo "✅ chaos test passed — clean up with: docker compose down -v"
