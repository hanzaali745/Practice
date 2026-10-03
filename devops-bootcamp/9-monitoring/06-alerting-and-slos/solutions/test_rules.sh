#!/usr/bin/env bash
# test_rules.sh — syntax-check and unit-test the rules with promtool (runs in CI too: no Prometheus needed)
set -euo pipefail
cd "$(dirname "$0")"
run() { docker run --rm --entrypoint promtool -v "$PWD:/work" -w /work prom/prometheus:v3.15.0 "$@"; }
run check rules rules/*.yml
run test rules tests/*.yml
