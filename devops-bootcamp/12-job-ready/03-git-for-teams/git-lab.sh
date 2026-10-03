#!/usr/bin/env bash
# git-lab.sh — realistic team Git situations to practise on, each with a fake "GitHub" (a bare origin) and a teammate.
#
#   ./git-lab.sh list                     the scenarios
#   ./git-lab.sh new NAME [DIR]           create one (default DIR: ~/git-lab/NAME) and print the task
#   ./git-lab.sh task NAME                print the task again
#   ./git-lab.sh check NAME [DIR]         did you solve it — the way a team needs it solved?
#
# Layout of every scenario:  DIR/origin.git (the shared remote) · DIR/work (YOUR clone — work here) · DIR/.lab (answers)
set -euo pipefail

scenarios=(conflict bisect lost-work messy-history leaked-secret revert-merge hotfix)
die() { echo "❌ $*" >&2; exit 1; }

# ---------- helpers ----------
clock=1767225600                                  # 2026-01-01: commits get fixed, increasing dates
commit_as() {                                     # commit_as "Name" "message"   (stages everything first)
    clock=$((clock + 3600))
    git add -A
    GIT_AUTHOR_DATE="@$clock +0000" GIT_COMMITTER_DATE="@$clock +0000" \
        git -c user.name="$1" -c user.email="$(tr '[:upper:]' '[:lower:]' <<< "${1%% *}")@example.com" \
        commit -q -m "$2"
}
start() {                                         # start DIR — create origin.git + an initial commit, cd into a seed clone
    [[ -e $1 ]] && die "$1 already exists — remove it or pass another DIR"
    mkdir -p "$1/.lab"
    git init -q --bare -b main "$1/origin.git"
    git clone -q "$1/origin.git" "$1/.lab/seed" 2> /dev/null
    cd "$1/.lab/seed"
    git checkout -q -b main 2> /dev/null || true
    git config user.name "Ada Lovelace"           # identity for tags and merges made while setting up
    git config user.email ada@example.com
}
finish_setup() {                                  # finish_setup DIR — your clone, with every branch and tag
    git clone -q "$1/origin.git" "$1/work"
    git -C "$1/work" config user.name "${GIT_LAB_NAME:-You}"
    git -C "$1/work" config user.email "you@example.com"
    rm -rf "$1/.lab/seed"
}
result=0
ok() { local d=$1; shift; if "$@" > /dev/null 2>&1; then echo "  ✅ $d"; else echo "  ❌ $d"; result=1; fi; }
o() { git -C "$dir/origin.git" "$@"; }            # run git against the shared remote

# ---------- tasks ----------
task() {
    case $1 in
    conflict) cat <<'EOF'
🧩 conflict — You changed replicas on feature/raise-replicas. Meanwhile Ada changed the same line on main, and the port.
   Team decision: replicas: 4 (yours), port: 8080 (Ada's), keep your new "timeout: 30".
   1. Bring your branch up to date with origin/main using REBASE (the team wants linear history, no merge commits).
   2. Resolve the conflict, finish the rebase, and push feature/raise-replicas (it was never pushed before).
EOF
    ;;
    bisect) cat <<'EOF'
🔎 bisect — total() in calc.py returns wrong results on main. v1.0 was fine. 30 commits since then, nobody knows which broke it.
   1. Use git bisect (bonus: `git bisect run` with ../test_total.sh) to find the FIRST bad commit.
   2. Write its full 40-character SHA into ../answer.txt, then `git bisect reset`.
EOF
    ;;
    lost-work) cat <<'EOF'
🛟 lost-work — A bad afternoon: someone ran `git reset --hard HEAD~2` on main (losing two finished commits) and
   `git branch -D feature/report` (three commits, never pushed). Nothing is on origin.
   Recover both: main must contain the two "feat:" commits again, and feature/report must exist with its 3 commits.
EOF
    ;;
    messy-history) cat <<'EOF'
🧹 messy-history — feature/healthcheck has 6 commits like "wip", "oops" and "fix typo". Before review, rewrite it as
   exactly TWO commits with Conventional Commit messages, e.g.
       feat(health): add healthcheck script and config
       docs(health): document the healthcheck
   The final CONTENT must not change. The branch is already pushed: update origin safely (--force-with-lease).
EOF
    ;;
    leaked-secret) cat <<'EOF'
🔐 leaked-secret — An AWS key was committed in .env months ago, "removed" in a later commit, and pushed (tag v1.0 too).
   It's still in the history. In real life, step 1 is ROTATING the key (assume done). Your job:
   1. Remove .env from ALL history on origin — every branch and tag (git filter-repo, in a fresh clone).
   2. Make sure it can't happen again: .env in .gitignore on main.
   3. Push the rewritten history (branches and tags) to origin.
EOF
    ;;
    revert-merge) cat <<'EOF'
⏪ revert-merge — PR "feature/new-cache" was merged to main and deployed; production is broken. Ada already pushed a
   changelog commit on top, and everyone has pulled main. Undo the feature on main WITHOUT rewriting history, keep
   Ada's changelog commit, and push.
EOF
    ;;
    hotfix) cat <<'EOF'
🚑 hotfix — release/1.4 is in production. main has a security fix ("fix: escape user input in greeting") but also new
   features that must NOT ship yet. Bring ONLY the fix to release/1.4 (cherry-pick, recording where it came from),
   create the annotated tag v1.4.1 on the result, and push the branch and the tag.
EOF
    ;;
    *) die "no scenario '$1' — ./git-lab.sh list" ;;
    esac
}

# ---------- scenario builders ----------
new_conflict() {
    start "$1"
    printf 'service: demo-app\nreplicas: 2\nport: 8000\nlog_level: info\n' > config.yaml
    printf '# demo-app deploy config\n' > README.md
    commit_as "Ada Lovelace" "chore: initial deploy config"
    git push -q origin main
    git checkout -q -b feature/raise-replicas
    sed -i 's/^replicas: 2/replicas: 4/' config.yaml
    printf 'timeout: 30\n' >> config.yaml
    commit_as "You" "feat(deploy): 4 replicas and a request timeout"
    git checkout -q main
    sed -i 's/^replicas: 2/replicas: 3/; s/^port: 8000/port: 8080/' config.yaml
    commit_as "Ada Lovelace" "feat(deploy): move to port 8080, 3 replicas"
    git push -q origin main
    git -C "$1/.lab/seed" bundle create -q "$1/.lab/mine.bundle" feature/raise-replicas
    finish_setup "$1"
    git -C "$1/work" fetch -q "$1/.lab/mine.bundle" feature/raise-replicas:feature/raise-replicas  # your unpushed branch
    git -C "$1/work" checkout -q feature/raise-replicas
    # your clone is from BEFORE Ada pushed: rewind origin/main by one so `git fetch` matters
    git -C "$1/work" update-ref refs/remotes/origin/main refs/remotes/origin/main~1
    git -C "$1/work" branch -q -f main origin/main
}
check_conflict() {
    ok "feature/raise-replicas is on origin" o rev-parse --verify feature/raise-replicas
    ok "it is based on the latest main (rebased)" o merge-base --is-ancestor main feature/raise-replicas
    ok "no merge commits on the branch (linear)" bash -c "[[ -z \$(git -C '$dir/origin.git' rev-list --merges main..feature/raise-replicas) ]]"
    ok "replicas: 4 (team decision)" bash -c "git -C '$dir/origin.git' show feature/raise-replicas:config.yaml | grep -qx 'replicas: 4'"
    ok "port: 8080 (Ada's change kept)" bash -c "git -C '$dir/origin.git' show feature/raise-replicas:config.yaml | grep -qx 'port: 8080'"
    ok "timeout: 30 (your change kept)" bash -c "git -C '$dir/origin.git' show feature/raise-replicas:config.yaml | grep -qx 'timeout: 30'"
    ok "no conflict markers left" bash -c "! git -C '$dir/origin.git' show feature/raise-replicas:config.yaml | grep -qE '^(<<<<<<<|=======|>>>>>>>)'"
}

new_bisect() {
    start "$1"
    cat > calc.py <<'EOF'
"""calc.py — order maths for the shop."""
TAX = 0.2


def total(prices):
    """Sum of all prices."""
    result = 0
    for p in prices:
        result += p
    return result


def with_tax(amount):
    return round(amount * (1 + TAX), 2)
EOF
    printf '# shop-calc\n' > README.md
    commit_as "Ada Lovelace" "feat: total and with_tax"
    local i authors=("Ada Lovelace" "Grace Hopper" "Linus Torvalds" "Margaret Hamilton")
    for i in $(seq 1 30); do
        case $i in
            4) git tag -a v1.0 -m "v1.0 (known good)" ;;
            19) python3 - <<'EOF'                  # the regression: an "optimisation" that skips the first item
import re
s = open("calc.py").read()
s = s.replace("    result = 0\n    for p in prices:\n        result += p\n    return result",
              "    return sum(prices[i] for i in range(1, len(prices)))")
open("calc.py", "w").write(s)
EOF
                commit_as "Grace Hopper" "refactor(calc): simplify total()"; continue ;;
        esac
        if (( i % 3 == 0 )); then
            printf 'DISCOUNT_%d = %d\n' "$i" "$i" >> calc.py
            commit_as "${authors[i % 4]}" "feat(calc): add discount tier $i"
        else
            printf -- '- change %d\n' "$i" >> README.md
            commit_as "${authors[i % 4]}" "docs: changelog entry $i"
        fi
    done
    git push -q origin main --tags
    git rev-list main --grep="simplify total" > "$1/.lab/first-bad"
    cat > "$1/test_total.sh" <<'EOF'
#!/bin/sh
# exit 0 = good, 1 = bad (what `git bisect run` expects). Run it from the repository folder.
python3 -c 'import calc; assert calc.total([1, 2, 3]) == 6, calc.total([1, 2, 3])'
EOF
    chmod +x "$1/test_total.sh"
    finish_setup "$1"
}
check_bisect() {
    ok "answer.txt holds the first bad commit" bash -c "[[ \$(tr -d '[:space:]' < '$dir/answer.txt') == \$(cat '$dir/.lab/first-bad') ]]"
    ok "bisect was reset (no bisect in progress)" bash -c "[[ ! -f '$dir/work/.git/BISECT_LOG' ]]"
}

new_lost_work() {
    start "$1"
    printf 'print("report v0")\n' > report.py
    commit_as "You" "chore: start the project"
    git push -q origin main
    finish_setup "$1"
    cd "$1/work"
    printf 'def a():\n    return "A"\n' > a.py; commit_as "You" "feat: important change A"
    printf 'def b():\n    return "B"\n' > b.py; commit_as "You" "feat: important change B"
    git checkout -q -b feature/report
    for n in 1 2 3; do printf 'print("report section %d")\n' "$n" >> report.py; commit_as "You" "feat(report): section $n"; done
    git checkout -q main
    git branch -q -D feature/report
    git reset -q --hard HEAD~2
}
check_lost_work() {
    # shellcheck disable=SC2329  # called through ok()
    has_msg() { git -C "$dir/work" log --format=%s "$1" 2> /dev/null | grep -x "$2" > /dev/null; }  # not grep -q: SIGPIPE + pipefail
    ok "main has 'feat: important change A'" has_msg main "feat: important change A"
    ok "main has 'feat: important change B'" has_msg main "feat: important change B"
    ok "feature/report exists" git -C "$dir/work" rev-parse --verify feature/report
    for n in 1 2 3; do ok "feature/report has 'feat(report): section $n'" has_msg feature/report "feat(report): section $n"; done
}

new_messy_history() {
    start "$1"
    printf '# service\n' > README.md
    commit_as "Ada Lovelace" "chore: init"
    git push -q origin main
    git checkout -q -b feature/healthcheck
    printf '#!/bin/sh\ncurl -sf http://localhost:8000/helth\n' > healthcheck.sh
    commit_as "You" "add healthcheck"
    mkdir -p docs; printf '# Healthcheck\nTODO\n' > docs/healthcheck.md
    commit_as "You" "wip"
    sed -i 's/helth/health/' healthcheck.sh
    commit_as "You" "fix typo"
    printf 'TIMEOUT=2\n' > healthcheck.conf
    commit_as "You" "oops forgot file"
    printf '# Healthcheck\n\nRun ./healthcheck.sh: it exits non-zero when the app is unhealthy.\n' > docs/healthcheck.md
    commit_as "You" "address review"
    printf 'exit $?\n' >> healthcheck.sh
    commit_as "You" "more wip"
    git push -q origin feature/healthcheck
    git rev-parse 'feature/healthcheck^{tree}' > "$1/.lab/tree"
    finish_setup "$1"
    git -C "$1/work" checkout -q feature/healthcheck
}
check_messy_history() {
    local re='^(feat|fix|docs|chore|refactor|test|ci|build|perf|style)(\([a-z0-9-]+\))?!?: .+'
    ok "origin's feature/healthcheck has exactly 2 commits on top of main" bash -c "[[ \$(git -C '$dir/origin.git' rev-list --count main..feature/healthcheck) == 2 ]]"
    ok "both messages are Conventional Commits" bash -c "! git -C '$dir/origin.git' log --format=%s main..feature/healthcheck | grep -vqE '$re'"
    ok "the final content is unchanged" bash -c "[[ \$(git -C '$dir/origin.git' rev-parse 'feature/healthcheck^{tree}') == \$(cat '$dir/.lab/tree') ]]"
    ok "no empty commits" bash -c "for c in \$(git -C '$dir/origin.git' rev-list main..feature/healthcheck); do [[ -n \$(git -C '$dir/origin.git' diff-tree --no-commit-id --name-only -r \$c) ]] || exit 1; done"
}

new_leaked_secret() {
    start "$1"
    printf 'import os\nKEY = os.environ.get("AWS_ACCESS_KEY_ID")\n' > app.py
    commit_as "Ada Lovelace" "feat: app skeleton"
    printf '# uploader\n' > README.md;                         commit_as "Ada Lovelace" "docs: readme"
    printf 'boto3\n' > requirements.txt;                       commit_as "Grace Hopper" "build: add boto3"
    printf 'AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE\nAWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY\n' > .env
    commit_as "Grace Hopper" "feat: configure uploads"
    git tag -a v1.0 -m "first release"
    printf 'print("upload")\n' >> app.py;                      commit_as "Grace Hopper" "feat: upload command"
    git rm -q .env;                                             commit_as "Ada Lovelace" "chore: remove .env"
    printf -- '- v1.1\n' >> README.md;                         commit_as "Ada Lovelace" "docs: changelog"
    git push -q origin main --tags
    finish_setup "$1"
}
check_leaked_secret() {
    ok "the secret is in NO commit on any branch or tag" bash -c "! git -C '$dir/origin.git' log --all -p | grep -q 'EXAMPLEKEY'"
    ok "no .env file in any commit" bash -c "[[ -z \$(git -C '$dir/origin.git' log --all --format=%H -- .env) ]]"
    ok "tag v1.0 still exists (rewritten, not deleted)" o rev-parse --verify v1.0
    ok ".env is in .gitignore on main" bash -c "git -C '$dir/origin.git' show main:.gitignore | grep -qxE '/?\.env'"
    ok "the rest of the project is intact" bash -c "git -C '$dir/origin.git' show main:app.py | grep -q upload"
}

new_revert_merge() {
    start "$1"
    printf 'cache: redis\n' > config.yaml
    printf '# Changelog\n' > CHANGELOG.md
    commit_as "Ada Lovelace" "chore: init"
    git checkout -q -b feature/new-cache
    printf 'cache: memcached\n' > config.yaml
    printf 'def get(key):\n    raise NotImplementedError\n' > cache.py
    commit_as "Grace Hopper" "feat(cache): switch to memcached"
    git checkout -q main
    GIT_AUTHOR_DATE="@$((clock + 100)) +0000" GIT_COMMITTER_DATE="@$((clock + 100)) +0000" \
        git -c user.name="Grace Hopper" -c user.email=grace@example.com merge -q --no-ff feature/new-cache -m "Merge pull request #42 from feature/new-cache"
    printf -- '- 2026-01: new cache\n' >> CHANGELOG.md
    commit_as "Ada Lovelace" "docs: changelog for the new cache"
    git push -q origin main feature/new-cache
    git rev-parse main > "$1/.lab/old-tip"
    finish_setup "$1"
}
check_revert_merge() {
    ok "history was NOT rewritten (the old main is still in main)" bash -c "git -C '$dir/origin.git' merge-base --is-ancestor \$(cat '$dir/.lab/old-tip') main"
    ok "the cache is back to redis" bash -c "git -C '$dir/origin.git' show main:config.yaml | grep -qx 'cache: redis'"
    ok "cache.py is gone" bash -c "! git -C '$dir/origin.git' cat-file -e main:cache.py"
    ok "Ada's changelog commit is kept" bash -c "git -C '$dir/origin.git' show main:CHANGELOG.md | grep -q 'new cache'"
    ok "there is a revert commit explaining it" bash -c "git -C '$dir/origin.git' log --format=%s main | grep -q '^Revert'"
}

new_hotfix() {
    start "$1"
    printf 'def greet(name):\n    return f"<p>Hello {name}</p>"\n' > greet.py
    commit_as "Ada Lovelace" "feat: greeting"
    git checkout -q -b release/1.4
    printf '1.4.0\n' > VERSION; commit_as "Ada Lovelace" "chore(release): 1.4.0"
    git tag -a v1.4.0 -m "1.4.0"
    git checkout -q main
    printf 'DARK = True\n' > theme.py;                         commit_as "Grace Hopper" "feat: dark mode"
    printf 'import html\n\n\ndef greet(name):\n    return f"<p>Hello {html.escape(name)}</p>"\n' > greet.py
    commit_as "Linus Torvalds" "fix: escape user input in greeting"
    git rev-parse HEAD > "$1/.lab/fix"
    printf 'BETA = True\n' > beta.py;                          commit_as "Grace Hopper" "feat: beta flag"
    git push -q origin main release/1.4 --tags
    finish_setup "$1"
}
check_hotfix() {
    ok "release/1.4 has the fix, cherry-picked with -x (records the original commit)" bash -c "git -C '$dir/origin.git' log --format=%B release/1.4 | grep -q \"cherry picked from commit \$(cat '$dir/.lab/fix')\""
    ok "greet.py on release/1.4 escapes input" bash -c "git -C '$dir/origin.git' show release/1.4:greet.py | grep -q html.escape"
    ok "no unreleased features on release/1.4" bash -c "! git -C '$dir/origin.git' cat-file -e release/1.4:theme.py && ! git -C '$dir/origin.git' cat-file -e release/1.4:beta.py"
    ok "v1.4.1 is an annotated tag" bash -c "[[ \$(git -C '$dir/origin.git' cat-file -t v1.4.1) == tag ]]"
    ok "v1.4.1 points at the tip of release/1.4" bash -c "[[ \$(git -C '$dir/origin.git' rev-parse 'v1.4.1^{commit}') == \$(git -C '$dir/origin.git' rev-parse release/1.4) ]]"
}

# ---------- main ----------
case ${1:-} in
    list) for s in "${scenarios[@]}"; do task "$s" | head -1; done ;;
    task) task "${2:?usage: git-lab.sh task NAME}" ;;
    new)
        name=${2:?usage: git-lab.sh new NAME [DIR]}
        [[ " ${scenarios[*]} " == *" $name "* ]] || die "no scenario '$name' — ./git-lab.sh list"
        dir=$(realpath -m "${3:-$HOME/git-lab/$name}")
        ( "new_${name//-/_}" "$dir" )
        echo "📁 $dir/work  (origin: $dir/origin.git)"; echo
        task "$name"
        echo; echo "👉 cd $dir/work — then ./git-lab.sh check $name ${3:-}" ;;
    check)
        name=${2:?usage: git-lab.sh check NAME [DIR]}
        dir=$(realpath -m "${3:-$HOME/git-lab/$name}")
        [[ -d $dir/origin.git ]] || die "$dir is not a git-lab scenario — ./git-lab.sh new $name first"
        "check_${name//-/_}"
        if (( result == 0 )); then echo "✅ solved"; else echo "❌ not yet"; exit 1; fi ;;
    *) sed -n '2,9p' "$0"; exit 2 ;;
esac
