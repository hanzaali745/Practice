#!/usr/bin/env bash
# Lab 4 — measure how long `docker stop` takes for exec-form vs shell-form CMD
set -euo pipefail
cd "$(dirname "$0")"

for form in exec shell; do
    docker build -q -f "Dockerfile.$form" -t "demo-stop:$form" . > /dev/null
    docker rm -f "stop-$form" > /dev/null 2>&1 || true
    docker run -d --name "stop-$form" "demo-stop:$form" > /dev/null
    sleep 1
    start=$(date +%s.%N)
    docker stop "stop-$form" > /dev/null
    end=$(date +%s.%N)
    printf '%-6s form: docker stop took %4.1fs, exit code %s\n' "$form" \
        "$(echo "$end - $start" | bc)" "$(docker inspect -f '{{.State.ExitCode}}' "stop-$form")"
    docker rm "stop-$form" > /dev/null
done
echo "exec: python got SIGTERM and exited cleanly (0). shell: sh ignored it, Docker waited 10s, then SIGKILL (137)."
