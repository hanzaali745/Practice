#!/usr/bin/env bash
# check_alertmanager.sh — validate alertmanager.yml and show where a given alert would be routed
set -euo pipefail
cd "$(dirname "$0")"
amtool() { docker run --rm --entrypoint amtool -v "$PWD/alertmanager.yml:/am.yml:ro" prom/alertmanager:v0.34.1 "$@"; }
amtool check-config /am.yml
echo "== routing tests"
echo -n "DemoAppDown (critical)        → "; amtool config routes test --config.file=/am.yml alertname=DemoAppDown severity=critical job=demo-app
echo -n "DemoAppHighErrorRate (warning) → "; amtool config routes test --config.file=/am.yml alertname=DemoAppHighErrorRate severity=warning
