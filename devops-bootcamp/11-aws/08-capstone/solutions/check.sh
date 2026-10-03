#!/usr/bin/env bash
# check.sh — the capstone's own quality gate
#   ./check.sh               offline: Terraform fmt/validate/test (mocked AWS), workflow lint + security, shellcheck
#   ./check.sh --local-aws   also apply the whole stack to local AWS, deploy a new revision with ecs_deploy.sh, destroy
#                            (start local AWS first: docker compose -f ../../local-aws/compose.yaml up -d; source env.sh)
set -uo pipefail
cd "$(dirname "$0")" || exit 2
here=$PWD
failed=0
check() {
    printf '%-46s' "$1"; shift
    local out
    if out=$("$@" 2>&1); then echo "✅"; else echo "❌"; printf '    %s\n' "${out//$'\n'/$'\n'    }" | tail -25; failed=1; fi
}
tf() { terraform -chdir=infra "$@"; }
# shellcheck disable=SC2329  # the functions below are called through check()
tf_init() { tf init -backend=false -input=false -no-color; }
# shellcheck disable=SC2329
lint_workflow() {                    # deploy-aws.yml calls ci.yml: lint it next to the Phase 8 capstone's ci.yml
    local tmp rc
    tmp=$(mktemp -d)
    chmod 755 "$tmp"                 # the actionlint container doesn't run as root
    mkdir -p "$tmp/.github/workflows"
    cp pipeline/.github/workflows/deploy-aws.yml ../../../8-cicd/08-capstone/solutions/pipeline/.github/workflows/ci.yml "$tmp/.github/workflows/"
    docker run --rm -v "$tmp:/repo" -w /repo rhysd/actionlint:1.7.12 -no-color .github/workflows/deploy-aws.yml
    rc=$?
    rm -r "$tmp"
    return $rc
}
# shellcheck disable=SC2329
zizmor_offline() { zizmor --offline --no-progress --min-severity medium pipeline/.github; }
# shellcheck disable=SC2329
pinned() { ! grep -rnE 'uses: [^ ./][^ ]*@' pipeline/.github | grep -vE '@[0-9a-f]{40}'; }
# shellcheck disable=SC2329
local_aws() {
    [[ -n ${AWS_ENDPOINT_URL:-} ]] || { echo "AWS_ENDPOINT_URL is not set: source ../../local-aws/env.sh" >&2; return 1; }
    local vars=(-var image_tag=sha-first -var github_repo=octo-org/demo-app -var autoscaling=false -var alarms=false) rc=0
    tf apply -auto-approve -input=false -no-color "${vars[@]}" > /dev/null || rc=1
    if (( rc == 0 )); then
        local repo
        repo=$(tf output -raw ecr_repository_url)
        ECS_CLUSTER=demo-app ECS_SERVICE=demo-app TASK_FAMILY=demo-app \
            "$here/pipeline/scripts/ecs_deploy.sh" "$repo@sha256:$(printf '0%.0s' {1..64})" || rc=1
    fi
    tf destroy -auto-approve -input=false -no-color "${vars[@]}" > /dev/null || rc=1
    return $rc
}

check "terraform fmt" tf fmt -check -recursive
check "terraform init (no backend)" tf_init
check "terraform validate" tf validate -no-color
check "terraform test (mocked AWS)" tf test -no-color
check "actionlint" lint_workflow
check "zizmor (offline)" zizmor_offline
check "every action pinned to a commit SHA" pinned
check "shellcheck" shellcheck ./*.sh pipeline/scripts/*.sh
if [[ ${1:-} == --local-aws ]]; then
    check "local AWS: apply → deploy revision 2 → destroy" local_aws
fi
(( failed )) && { echo "❌ capstone checks failed"; exit 1; }
echo "✅ capstone checks passed"
