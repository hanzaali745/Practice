#!/usr/bin/env bash
# Module 07 — the quality gate a CI pipeline runs for an Ansible project.
#
# Usage: ./quality.sh [PROJECT_DIR] [--deploy] [--molecule]
#   PROJECT_DIR  defaults to ../../06-vault-and-secrets/solutions
#   --deploy     also run against the lab fleet: dry run, idempotence, smoke test
#   --molecule   also run the Molecule scenario for the demo_app role
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
project="$here/../../06-vault-and-secrets/solutions"
deploy=false molecule=false
for arg in "$@"; do
    case $arg in
        --deploy) deploy=true ;;
        --molecule) molecule=true ;;
        -*) echo "unknown option: $arg" >&2; exit 2 ;;
        *) project=$arg ;;
    esac
done
project=$(cd "$project" && pwd)
cd "$project"
[[ -f .vault-pass ]] && export ANSIBLE_VAULT_PASSWORD_FILE="$project/.vault-pass"

failed=0
step() {                       # step NAME COMMAND... — run, report, keep going
    local name=$1; shift
    printf '%-34s' "$name"
    if "$@" > "$here/.last-step.log" 2>&1 </dev/null; then
        echo "✅"
    else
        echo "❌"; sed 's/^/    /' "$here/.last-step.log" | tail -25
        failed=1
    fi
}

playbooks=()
for f in ./*.yml; do
    [[ -f $f && $f != ./requirements.yml ]] && playbooks+=("$f")
done

echo "Project: $project"
step "yamllint"                 yamllint -c "$here/.yamllint" .
step "ansible-lint (production)" ansible-lint -c "$here/.ansible-lint"
for pb in "${playbooks[@]}"; do
    step "syntax-check $(basename "$pb")" ansible-playbook --syntax-check "$pb"
done
if [[ -x "$project/check_vault_files.sh" ]]; then
    step "vault files encrypted" "$project/check_vault_files.sh"
fi

if $deploy; then
    step "dry run (--check --diff)"   ansible-playbook site.yml --check --diff
    step "idempotence"                "$here/../../02-playbooks/solutions/idempotence.sh" site.yml
    step "smoke test web1 + web2"     bash -c 'curl -fsS localhost:8081/health && curl -fsS localhost:8082/health'
fi

if $molecule; then
    step "molecule test -s demo_app"  bash -c "cd '$here' && molecule test -s demo_app"
fi

rm -f "$here/.last-step.log"
if (( failed )); then echo "❌ quality gate FAILED"; exit 1; fi
echo "✅ quality gate passed"
