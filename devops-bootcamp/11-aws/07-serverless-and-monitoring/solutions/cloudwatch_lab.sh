#!/usr/bin/env bash
# cloudwatch_lab.sh | --cleanup — the CloudWatch toolbox in one run:
#   SNS topic (+ email) · log group with retention · metric filter (logs → metric) · alarm → SNS · dashboard
# ALERT_EMAIL=you@example.com ./cloudwatch_lab.sh   to get the alarm by email (confirm the subscription first).
# Local AWS: works except for the email and for metrics actually being computed from logs. ☁️ Real AWS: free tier.
set -euo pipefail
cd "$(dirname "$0")"
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
group=/demo/app

if [[ ${1:-} == --cleanup ]]; then
    aws cloudwatch delete-alarms --alarm-names demo-app-errors 2>/dev/null || true
    aws cloudwatch delete-dashboards --dashboard-names demo-app 2>/dev/null || true
    aws logs delete-log-group --log-group-name "$group" 2>/dev/null || true
    topic=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':demo-alerts')].TopicArn" --output text)
    [[ -z $topic ]] || aws sns delete-topic --topic-arn "$topic"
    echo "deleted the CloudWatch lab"; exit 0
fi

say "1. Where alerts go: an SNS topic"
topic=$(aws sns create-topic --name demo-alerts --query TopicArn --output text)
echo "$topic"
if [[ -n ${ALERT_EMAIL:-} ]]; then
    aws sns subscribe --topic-arn "$topic" --protocol email --notification-endpoint "$ALERT_EMAIL" > /dev/null
    echo "check $ALERT_EMAIL and confirm the subscription"
fi

say "2. A log group with retention, and some demo-app JSON logs in it"
aws logs create-log-group --log-group-name "$group"
aws logs put-retention-policy --log-group-name "$group" --retention-in-days 14
aws logs create-log-stream --log-group-name "$group" --log-stream-name lab
now=$(($(date +%s) * 1000))
events=$(python3 - "$now" <<'PY'
import json, sys
now = int(sys.argv[1])
lines = [("info", "GET / 200 3.1ms"), ("info", "GET /health 200 0.4ms"), ("error", "GET /error 500 0.9ms"),
         ("warn", "GET /nope 404 0.5ms"), ("error", "GET /error 500 1.2ms")]
print(json.dumps([{"timestamp": now + i, "message": json.dumps({"log": {"level": lvl}, "message": msg})}
                  for i, (lvl, msg) in enumerate(lines)]))
PY
)
aws logs put-log-events --log-group-name "$group" --log-stream-name lab --log-events "$events" > /dev/null
echo "5 events written"

say "3. A metric filter: every log line with log.level = error adds 1 to DemoApp/Errors"
pattern='{ $.log.level = "error" }'
aws logs put-metric-filter --log-group-name "$group" --filter-name errors --filter-pattern "$pattern" \
    --metric-transformations metricName=Errors,metricNamespace=DemoApp,metricValue=1,defaultValue=0
if [[ -z ${AWS_ENDPOINT_URL:-} ]]; then          # ☁️ test a pattern against sample lines before trusting it
    aws logs test-metric-filter --filter-pattern "$pattern" \
        --log-event-messages '{"log":{"level":"error"},"message":"boom"}' '{"log":{"level":"info"},"message":"ok"}' \
        --query 'matches[].eventMessage' --output text
fi
aws logs describe-metric-filters --log-group-name "$group" --query 'metricFilters[].[filterName, filterPattern]' --output text

say "4. An alarm: 5+ errors in 5 minutes → SNS (and again when it recovers)"
aws cloudwatch put-metric-alarm --alarm-name demo-app-errors \
    --alarm-description "demo-app logs 5+ errors in 5 minutes. Runbook: 9-monitoring/08-capstone/solutions/platform/runbooks/demo-app.md" \
    --namespace DemoApp --metric-name Errors --statistic Sum --period 300 --evaluation-periods 1 \
    --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching \
    --alarm-actions "$topic" --ok-actions "$topic"

say "5. Test the alert path without breaking anything: force the alarm state"
aws cloudwatch set-alarm-state --alarm-name demo-app-errors --state-value ALARM --state-reason "lab: testing notifications"
aws cloudwatch describe-alarms --alarm-names demo-app-errors \
    --query 'MetricAlarms[0].{Alarm: AlarmName, State: StateValue, Reason: StateReason}' --output table

say "6. A dashboard"
aws cloudwatch put-dashboard --dashboard-name demo-app --dashboard-body file://dashboard.json --query 'DashboardValidationMessages' --output text
aws cloudwatch list-dashboards --query 'DashboardEntries[].DashboardName' --output text

cat <<'TXT'

☁️ Logs Insights (console → CloudWatch → Logs Insights, group /demo/app):
    fields @timestamp, message | filter log.level = "error" | stats count() by bin(5m)
✅ clean up with: ./cloudwatch_lab.sh --cleanup
TXT
