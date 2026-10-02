#!/bin/sh
# check_setup.sh — verify your Ubuntu lab is ready for the bootcamp.
# Usage: sh 00-ubuntu-setup/check_setup.sh

failed=0

check() {
    # $1 = description, rest = command to test
    desc="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        printf '✅ %s\n' "$desc"
    else
        printf '❌ %s\n' "$desc"
        failed=$((failed + 1))
    fi
}

echo "== Operating system =="
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "   $PRETTY_NAME"
fi

echo "== Commands =="
for cmd in python3 git curl jq shellcheck bats bash dash tree bc ping nc; do
    check "$cmd installed" command -v "$cmd"
done

echo "== Python =="
check "python3 is 3.10 or newer" python3 -c 'import sys; sys.exit(sys.version_info < (3, 10))'
check "venv module available" python3 -c 'import venv, ensurepip'
check "virtual environment is active" test -n "${VIRTUAL_ENV:-}"
check "requests library" python3 -c 'import requests'
check "yaml library" python3 -c 'import yaml'
check "pytest library" python3 -c 'import pytest'

echo "== Bash =="
# shellcheck disable=SC2016  # single quotes on purpose: bash expands it, not sh
check "bash is version 4 or newer" bash -c '[ "${BASH_VERSINFO[0]}" -ge 4 ]'

echo
if [ "$failed" -eq 0 ]; then
    echo "🎉 All good — start with 1-python/01-getting-started/README.md"
else
    echo "⚠️  $failed check(s) failed — see 00-ubuntu-setup/README.md Steps 3 and 5"
    exit 1
fi
