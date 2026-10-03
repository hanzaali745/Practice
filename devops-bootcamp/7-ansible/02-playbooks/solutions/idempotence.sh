#!/usr/bin/env bash
# Lab 4 — run a playbook twice; fail if the second run changes anything
# Usage: ./idempotence.sh PLAYBOOK [extra ansible-playbook args...]
set -euo pipefail

playbook="${1:?Usage: $0 PLAYBOOK [args...]}"
shift

echo "== first run"
ansible-playbook "$playbook" "$@" > /dev/null

echo "== second run"
recap=$(ansible-playbook "$playbook" "$@" | sed -n '/PLAY RECAP/,$p')
echo "$recap"

if grep -Eq 'changed=[1-9]' <<< "$recap"; then
    echo "❌ NOT idempotent: the second run changed something" >&2
    exit 1
fi
echo "✅ idempotent: changed=0 on every host"
