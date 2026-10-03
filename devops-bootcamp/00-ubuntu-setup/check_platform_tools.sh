#!/bin/sh
# check_platform_tools.sh — verify the Phase 8-11 tools (CI/CD, Monitoring, ELK, AWS).
# Usage: sh 00-ubuntu-setup/check_platform_tools.sh

failed=0

check() {
    desc="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        printf '✅ %s\n' "$desc"
    else
        printf '❌ %s\n' "$desc"
        failed=$((failed + 1))
    fi
}

echo "== CI/CD =="
check "gh installed"                        command -v gh
check "gh is logged in"                     gh auth status
check "act installed"                       command -v act
check "actionlint installed"                command -v actionlint
check "act runner image pulled"             docker image inspect catthehacker/ubuntu:act-24.04

echo "== Python packages (venv) =="
check "virtual environment is active"       test -n "${VIRTUAL_ENV:-}"
check "zizmor installed"                    command -v zizmor
check "prometheus-client importable"        python3 -c "import prometheus_client"
check "boto3 importable"                    python3 -c "import boto3"
check "moto server installed"               command -v moto_server
check "git-filter-repo installed"            command -v git-filter-repo
check "pre-commit installed"                 command -v pre-commit

echo "== AWS =="
check "aws cli v2 installed"                sh -c 'aws --version 2>&1 | grep -q "aws-cli/2"'

echo "== Elasticsearch prerequisites =="
map_count=$(cat /proc/sys/vm/max_map_count 2>/dev/null || echo 0)
check "vm.max_map_count >= 262144 (found $map_count)" test "$map_count" -ge 262144
mem_gb=$(awk '/^MemTotal:/ { printf "%d", $2 / 1024 / 1024 }' /proc/meminfo)
check "at least 7 GB RAM (found ${mem_gb} GB)" test "$mem_gb" -ge 7

echo
if [ "$failed" -eq 0 ]; then
    echo "🎉 All good — start Phase 8: 8-cicd/01-cicd-concepts-and-first-workflow/README.md"
else
    echo "⚠️  $failed check(s) failed — see 00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md"
    exit 1
fi
