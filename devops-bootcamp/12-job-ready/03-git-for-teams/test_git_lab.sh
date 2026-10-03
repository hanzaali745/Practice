#!/usr/bin/env bash
# test_git_lab.sh — prove every scenario works: new → check FAILS → reference solution → check PASSES
set -uo pipefail
cd "$(dirname "$0")" || exit 2
export GIT_AUTHOR_NAME=Tester GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=Tester GIT_COMMITTER_EMAIL=t@example.com
tmp=$(mktemp -d)
failed=0
for name in conflict bisect lost-work messy-history leaked-secret revert-merge hotfix; do
    printf '%-15s' "$name"
    ./git-lab.sh new "$name" "$tmp/$name" > /dev/null 2>&1 || { echo "❌ setup failed"; failed=1; continue; }
    if ./git-lab.sh check "$name" "$tmp/$name" > /dev/null 2>&1; then echo "❌ check passes before solving"; failed=1; continue; fi
    (cd "$tmp/$name/work" && bash "$OLDPWD/solutions/git-fixes/$name.sh") > "$tmp/$name.log" 2>&1
    if out=$(./git-lab.sh check "$name" "$tmp/$name" 2>&1); then echo "✅"; else
        echo "❌ still failing after the reference solution"; grep "❌" <<< "$out" | sed 's/^/    /'; tail -5 "$tmp/$name.log" | sed 's/^/    log: /'; failed=1
    fi
done
rm -rf "$tmp"
exit $failed
