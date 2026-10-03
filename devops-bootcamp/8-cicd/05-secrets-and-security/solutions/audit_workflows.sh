#!/usr/bin/env bash
# audit_workflows.sh [REPO_DIR] — security review of .github/workflows: actionlint + zizmor + pinning + permissions
# shellcheck disable=SC2329  # the check functions are called indirectly, through check()
set -uo pipefail
cd "${1:-.}" || exit 2
dir=.github/workflows
[[ -d $dir ]] || { echo "no $dir here" >&2; exit 2; }
failed=0
check() {                                     # check NAME COMMAND... — run, print ✅/❌ and the output on failure
    printf '%-36s' "$1"; shift
    local out
    if out=$("$@" 2>&1); then echo "✅"; else echo "❌"; printf '    %s\n' "${out//$'\n'/$'\n'    }" | head -20; failed=1; fi
}


check "actionlint (syntax + shellcheck)" docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:1.7.12 -no-color
# zizmor's online audits (impostor commits, tag confusion) need a GitHub token: gh auth token, or GH_TOKEN
zizmor_mode=(--offline)
[[ -n ${GH_TOKEN:-} ]] && zizmor_mode=()
check "zizmor (security linter)" zizmor --no-progress --min-severity medium "${zizmor_mode[@]}" "$dir"

unpinned() { ! grep -nE 'uses: [^ ./][^ ]*@' "$dir"/*.y*ml | grep -vE '@[0-9a-f]{40}'; }
check "third-party actions pinned to SHAs" unpinned

no_perms() { local f bad=0; for f in "$dir"/*.y*ml; do grep -q '^permissions:' "$f" || { echo "$f: no top-level permissions:"; bad=1; }; done; return "$bad"; }
check "top-level permissions declared" no_perms

no_prt() { ! grep -nE '^\s*pull_request_target:' "$dir"/*.y*ml; }
check "no pull_request_target" no_prt

exit $failed
