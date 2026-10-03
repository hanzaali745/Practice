#!/usr/bin/env bash
# reload.sh — check the config, then tell the running Prometheus to re-read it (no restart, no lost data)
set -euo pipefail
cd "$(dirname "$0")"
./check_config.sh
curl -fsS -X POST http://localhost:9090/-/reload
echo "reloaded — last reload successful: $(curl -fsS http://localhost:9090/api/v1/status/runtimeinfo \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["reloadConfigSuccess"])')"
