#!/usr/bin/env bash
# check.sh — the capstone's own quality gate (static checks; no GitHub or cluster needed)
#   ./check.sh                 workflows, actions, scripts and manifests
#   ./check.sh --act LAB_REPO  also run the ci workflow locally with act on a copy of your lab repo
set -uo pipefail
cd "$(dirname "$0")" || exit 2
failed=0
check() {
    printf '%-40s' "$1"; shift
    local out
    if out=$("$@" 2>&1); then echo "✅"; else echo "❌"; printf '    %s\n' "${out//$'\n'/$'\n'    }" | tail -25; failed=1; fi
}
# shellcheck disable=SC2329  # the functions below are called through check()
lint_workflows() { docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:1.7.12 -no-color .github/workflows/*.yml; }
zizmor_offline() { zizmor --offline --no-progress --min-severity medium .github; }
pinned() { ! grep -rnE 'uses: [^ ./][^ ]*@' .github | grep -vE '@[0-9a-f]{40}'; }
manifests() {
    local env
    for env in staging production; do
        kubectl kustomize "deploy/overlays/$env" | kubeconform -strict -summary - || return 1
    done
}
gitlab_yaml() { python3 -c 'import sys, yaml; yaml.safe_load(open("other-ci/.gitlab-ci.yml"))'; }
run_act() {
    local tmp
    tmp=$(mktemp -d)
    cp -r "$1/." "$tmp/" && ./install_into.sh "$tmp" > /dev/null &&
        (cd "$tmp" && act push -e act-event.json -W .github/workflows/ci.yml -P ubuntu-latest=catthehacker/ubuntu:act-24.04)
    local rc=$?
    rm -rf "$tmp"
    return $rc
}

check "actionlint" lint_workflows
check "zizmor (offline)" zizmor_offline
check "every action pinned to a commit SHA" pinned
check "shellcheck" shellcheck scripts/*.sh ./*.sh
check "overlays render + kubeconform" manifests
check "GitLab CI file is valid YAML" gitlab_yaml
if [[ ${1:-} == --act ]]; then
    check "act: ci workflow on a copy of ${2:?--act needs LAB_REPO}" run_act "$2"
fi
(( failed )) && { echo "❌ capstone checks failed"; exit 1; }
echo "✅ capstone checks passed"
