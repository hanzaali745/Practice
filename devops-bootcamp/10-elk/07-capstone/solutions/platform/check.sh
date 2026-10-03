#!/usr/bin/env bash
# check.sh — the logging platform's quality gate
#   ./check.sh         static: Logstash pipeline, Filebeat config, Kibana saved objects
#   ./check.sh --e2e   + start everything; logs arrive parsed; security holds; ILM attached; dashboards import;
#                        an error spike fires a log alert and it resolves (~10 minutes)
set -uo pipefail
cd "$(dirname "$0")" || exit 2
# shellcheck disable=SC1091  # .env is optional
if [[ -f .env ]]; then set -a; . ./.env; set +a; fi
ES=http://localhost:9200
EPW=${ELASTIC_PASSWORD:-bootcamp-elastic}
failed=0
check() {
    printf '%-48s' "$1"; shift
    local out
    if out=$("$@" 2>&1); then echo "✅"; else echo "❌"; printf '    %s\n' "${out//$'\n'/$'\n'    }" | tail -15; failed=1; fi
}
# shellcheck disable=SC2329  # the functions below are called through check()
logstash_config() {
    local out
    out=$(docker run --rm -v "$PWD/logstash/pipeline:/usr/share/logstash/pipeline:ro" -e LOGSTASH_PASSWORD=x \
        -e XPACK_MONITORING_ENABLED=false elastic/logstash:9.5.4 \
        logstash --config.test_and_exit -f /usr/share/logstash/pipeline/demo.conf 2>&1)
    grep -q "Configuration OK" <<< "$out" || { echo "$out" | tail -5; return 1; }
}
filebeat_config() {
    docker run --rm -v "$PWD/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro" elastic/filebeat:9.5.4 \
        test config --strict.perms=false
}
ndjson_valid() { python3 -c 'import json; [json.loads(l) for l in open("kibana/demo-logs.ndjson")]'; }
q() { curl -fsS -u "elastic:$EPW" -H 'Content-Type: application/json' "$@"; }
count_ds() { q "$ES/logs-$1-capstone/_count" | python3 -c 'import json,sys; c=json.load(sys.stdin)["count"]; print(c); sys.exit(0 if c > 20 else 1)'; }
parsed_nginx() {
    q -X POST "$ES/logs-nginx-capstone/_search?size=0" -d '{"aggs": {"codes": {"terms": {"field": "http.response.status_code"}}}}' \
      | python3 -c 'import json,sys; b=json.load(sys.stdin)["aggregations"]["codes"]["buckets"]; print(b); sys.exit(0 if b else 1)'
}
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
anon_rejected() { [[ $(code "$ES/") == 401 ]]; }
dev_read_only() {
    [[ $(code -u "dev:${DEV_PASSWORD:-bootcamp-dev}" "$ES/logs-nginx-capstone/_search") == 200 ]] &&
    [[ $(code -u "dev:${DEV_PASSWORD:-bootcamp-dev}" -X DELETE "$ES/_data_stream/logs-nginx-capstone") == 403 ]]
}
writer_cannot_read() { [[ $(code -u "logstash_internal:${LOGSTASH_PASSWORD:-bootcamp-logstash}" "$ES/logs-nginx-capstone/_search") == 403 ]]; }
ilm_attached() { q "$ES/logs-demoapp-capstone/_ilm/explain" | grep -q '"policy":"logs-demo-14d"'; }
received() { docker compose exec -T receiver cat /data/notifications.jsonl 2>/dev/null | grep -q "\"status\": \"$1\", \"alerts\": \[\"LogErrorSpike\""; }
wait_until() { local t=$1; shift; for _ in $(seq "$((t / 10))"); do "$@" > /dev/null 2>&1 && return 0; sleep 10; done; "$@"; }

echo "== static"
check "Logstash pipeline (--config.test_and_exit)"  logstash_config
check "Filebeat config (test config)"               filebeat_config
check "Kibana saved objects are valid NDJSON"       ndjson_valid

if [[ ${1:-} == --e2e ]]; then
    echo "== end to end"
    check "stack starts"                            docker compose up -d --build --quiet-pull
    check "app logs arrive (logs-demoapp-capstone)" wait_until 240 count_ds demoapp
    check "nginx logs arrive and are parsed"        wait_until 60 parsed_nginx
    check "anonymous access is rejected"            anon_rejected
    check "dev can read but not delete"             dev_read_only
    check "logstash user can append but not read"   writer_cannot_read
    check "ILM policy attached to the data stream"  ilm_attached
    check "Kibana dashboards import"                ./kibana_setup.sh
    ERROR_FRACTION=0.5 docker compose up -d load > /dev/null 2>&1
    check "error spike fires LogErrorSpike"         wait_until 180 received firing
    ERROR_FRACTION=0.002 docker compose up -d load > /dev/null 2>&1
    check "back to normal: alert resolves"          wait_until 240 received resolved
    echo "   (stop it with: docker compose down -v)"
fi
(( failed )) && { echo "❌ checks failed"; exit 1; }
echo "✅ all checks passed"
