#!/usr/bin/env bash
# Capstone quality gate + end-to-end test against the lab fleet.
#
# Usage: ./check.sh            static checks only (no servers needed)
#        ./check.sh --e2e      + deploy, idempotence, a good release, a BAD release that must roll back
#        ./check.sh --e2e --molecule
set -euo pipefail
cd "$(dirname "$0")"

e2e=false molecule=false
for arg in "$@"; do
    case $arg in
        --e2e) e2e=true ;;
        --molecule) molecule=true ;;
        *) echo "usage: $0 [--e2e] [--molecule]" >&2; exit 2 ;;
    esac
done

# LAB ONLY — the course publishes this password; real projects read it from a secret store.
[[ -f .vault-pass ]] || { printf '%s\n' 'bootcamp-lab-vault' > .vault-pass; chmod 600 .vault-pass; }
export ANSIBLE_VAULT_PASSWORD_FILE="$PWD/.vault-pass"

failed=0
step() {                       # step NAME COMMAND... — run it, print ✅/❌, keep going
    local name=$1; shift
    printf '%-40s' "$name"
    if "$@" > .check-step.log 2>&1 </dev/null; then
        echo "✅"
    else
        echo "❌"; sed 's/^/    /' .check-step.log | tail -25
        failed=1
    fi
}

recap_changed() {              # print the total "changed=" count from a PLAY RECAP
    sed -n '/PLAY RECAP/,$p' | grep -o 'changed=[0-9]*' | awk -F= '{ sum += $2 } END { print sum + 0 }'
}

idempotent() {
    local n
    n=$(ansible-playbook site.yml | recap_changed)
    echo "changed on second run: $n"
    [[ $n -eq 0 ]]
}

version_on() { curl -fsS "localhost:$1/" | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])'; }

good_release() {
    ansible-playbook deploy.yml -e release_version=2.1.0
    [[ $(version_on 8081) == 2.1.0 && $(version_on 8082) == 2.1.0 ]]
}

bad_release() {                # must FAIL on web1, roll web1 back, and never touch web2
    if ansible-playbook deploy.yml -e release_version=2.2.0 -e '{"release_extra_env": {"REDIS_PORT": "not-a-port"}}'; then
        echo "the bad release was NOT stopped"; return 1
    fi
    echo "web1=$(version_on 8081) web2=$(version_on 8082)"
    [[ $(version_on 8081) == 2.1.0 && $(version_on 8082) == 2.1.0 ]]
}

no_secret_in_logs() {
    local pw
    pw=$(ansible-vault view inventories/lab/group_vars/all/vault.yml | sed -n 's/^vault_redis_password: "\(.*\)"/\1/p')
    [[ -n $pw ]] || { echo "could not read the vault"; return 1; }
    ! ansible-playbook site.yml --check --diff -v | grep -qF "$pw"
}

echo "== static checks"
step "yamllint"                          yamllint -c .yamllint .
step "ansible-lint (production)"         ansible-lint -c .ansible-lint
step "syntax-check site.yml"             ansible-playbook --syntax-check site.yml
step "syntax-check deploy.yml"           ansible-playbook --syntax-check deploy.yml
step "vault files encrypted"             ./check_vault_files.sh

if $molecule; then
    echo "== role tests"
    step "molecule test -s demo_app"     molecule test -s demo_app
fi

if $e2e; then
    echo "== end to end (lab fleet)"
    step "deploy site.yml"               ansible-playbook site.yml
    step "idempotence (changed=0)"       idempotent
    step "no secrets in --diff -v output" no_secret_in_logs
    step "rolling release 2.1.0"         good_release
    step "bad release 2.2.0 rolls back"  bad_release
    step "back to the inventory version" ansible-playbook site.yml
fi

rm -f .check-step.log
if (( failed )); then echo "❌ FAILED"; exit 1; fi
echo "✅ all checks passed"
