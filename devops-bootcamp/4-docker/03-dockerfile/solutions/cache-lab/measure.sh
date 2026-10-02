#!/usr/bin/env bash
# Lab 3 — time builds to see the cache at work
set -euo pipefail
cd "$(dirname "$0")"

build() {
    local start=$SECONDS
    docker build -q -t cache-lab . > /dev/null
    printf '  %3ss  %s\n' "$(( SECONDS - start ))" "$1"
}

docker builder prune -af > /dev/null
build "(a) first build"
build "(b) no changes"
echo "# edit $(date +%s%N)" >> app.py
build "(c) app.py changed   → pip layer still CACHED"
echo "# $(date +%s%N)" >> requirements.txt
build "(d) requirements changed → pip install runs again"
# restore the files
sed -i '/^# edit /d' app.py
sed -i '/^# [0-9]/d' requirements.txt
