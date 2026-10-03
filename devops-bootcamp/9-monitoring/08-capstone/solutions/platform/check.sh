#!/usr/bin/env bash
# check.sh — the observability platform's quality gate
#   ./check.sh          static: Prometheus config, rules + unit tests, Alertmanager config, dashboards, runbooks
#   ./check.sh --e2e    + start everything, verify every target and dashboard, break things, verify alerts + pages
set -uo pipefail
cd "$(dirname "$0")" || exit 2
failed=0
check() {
    printf '%-46s' "$1"; shift
    local out
    if out=$("$@" 2>&1); then echo "✅"; else echo "❌"; printf '    %s\n' "${out//$'\n'/$'\n'    }" | tail -20; failed=1; fi
}
promtool() { docker run --rm --entrypoint promtool -v "$PWD:/w" -w /w prom/prometheus:v3.15.0 "$@"; }
amtool() { docker run --rm --entrypoint amtool -v "$PWD:/w" -w /w prom/alertmanager:v0.34.1 "$@"; }
# shellcheck disable=SC2329  # the functions below are called through check()
dashboards_json() { python3 -c 'import json, glob; [json.load(open(f)) for f in glob.glob("grafana/dashboards/*.json")]'; }
runbooks_cover_alerts() {
    python3 - <<'PY'
import re, sys, yaml, glob
anchors = {h.strip().lower() for h in re.findall(r"^## (.+)$", open("runbooks/demo-app.md").read(), re.M)}
missing = [r["alert"] for f in glob.glob("rules/*.yml") for g in yaml.safe_load(open(f))["groups"]
           for r in g["rules"] if "alert" in r and r["alert"].lower() not in anchors]
no_link = [r["alert"] for f in glob.glob("rules/*.yml") for g in yaml.safe_load(open(f))["groups"]
           for r in g["rules"] if "alert" in r and "runbook_url" not in r.get("annotations", {})]
print("no runbook section:", missing, "| no runbook_url:", no_link)
sys.exit(1 if missing or no_link else 0)
PY
}
targets_up() {
    curl -fsS localhost:9090/api/v1/targets | python3 -c '
import json, sys
t = json.load(sys.stdin)["data"]["activeTargets"]
down = [x["labels"]["job"] + " " + x["labels"]["instance"] for x in t if x["health"] != "up"]
print(len(t), "targets, down:", down)
sys.exit(1 if down or len(t) < 8 else 0)   # prometheus, app x3, redis, node, alertmanager, blackbox'
}
firing() {                                  # firing ALERTNAME → succeeds once Alertmanager has it active
    curl -fsS "localhost:9093/api/v2/alerts?active=true&silenced=false&inhibited=false" \
        | python3 -c "import json, sys; sys.exit(0 if '$1' in {a['labels']['alertname'] for a in json.load(sys.stdin)} else 1)"
}
wait_until() { local t=$1; shift; for _ in $(seq "$((t / 10))"); do "$@" && return 0; sleep 10; done; "$@"; }
paged() { docker compose exec -T receiver cat /data/notifications.jsonl | grep -q "\"channel\": \"pager\", \"status\": \"$1\", \"alerts\": \[\"$2\""; }

echo "== static"
check "promtool check config"               promtool check config prometheus.yml
check "promtool check rules"                promtool check rules rules/alerts.yml rules/recording.yml rules/slo.yml
check "promtool test rules (unit tests)"    promtool test rules tests/alerts_test.yml tests/slo_test.yml tests/site_test.yml
check "amtool check-config"                 amtool check-config alertmanager.yml
check "dashboards are valid JSON"           dashboards_json
check "every alert has a runbook"           runbooks_cover_alerts

if [[ ${1:-} == --e2e ]]; then
    echo "== end to end (takes ~8 minutes)"
    check "stack starts"                    docker compose up -d --build --quiet-pull
    sleep 90
    check "all targets up"                  targets_up
    check "every dashboard panel has data"  python3 check_dashboards.py
    check "site answers through nginx"      curl -fsS localhost:8080/health
    docker compose stop nginx > /dev/null 2>&1
    check "nginx down: SiteUnreachable fires"  wait_until 180 firing SiteUnreachable
    check "  … and it paged"                wait_until 60 paged firing SiteUnreachable
    docker compose start nginx > /dev/null 2>&1
    check "nginx back: resolved page sent"     wait_until 240 paged resolved SiteUnreachable
    echo "   (stop it with: docker compose down -v)"
fi
(( failed )) && { echo "❌ checks failed"; exit 1; }
echo "✅ all checks passed"
