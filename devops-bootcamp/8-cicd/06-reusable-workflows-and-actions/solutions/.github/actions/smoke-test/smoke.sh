#!/usr/bin/env bash
# smoke_test.sh URL [EXPECTED_VERSION] — fail unless demo-app answers healthy (and with the right version)
set -euo pipefail
url=${1:?usage: smoke_test.sh URL [EXPECTED_VERSION]}
want=${2:-}

for attempt in $(seq 1 30); do
    if body=$(curl -fs --max-time 3 "$url/" 2>/dev/null); then
        version=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])' <<< "$body")
        if [[ -z $want || $version == "$want" ]]; then
            curl -fsS --max-time 3 "$url/health" > /dev/null
            echo "✅ $url is healthy (version $version, attempt $attempt)"
            exit 0
        fi
        echo "waiting: version is $version, want $want"
    fi
    sleep 2
done
echo "❌ $url did not become healthy${want:+ with version $want}" >&2
exit 1
