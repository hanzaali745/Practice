#!/usr/bin/env bash
# check_config.sh — validate prometheus.yml with promtool BEFORE you reload (like nginx -t)
set -euo pipefail
cd "$(dirname "$0")"
docker run --rm --entrypoint promtool \
    -v "$PWD/prometheus.yml:/etc/prometheus/prometheus.yml:ro" -v "$PWD/targets:/etc/prometheus/targets:ro" \
    prom/prometheus:v3.15.0 check config /etc/prometheus/prometheus.yml
