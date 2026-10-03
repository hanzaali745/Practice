#!/usr/bin/env bash
# pin_actions.sh WORKFLOW.yml... — replace "uses: owner/repo@vX" with the full commit SHA of the newest vX.* release
#   uses: actions/checkout@v7   →   uses: actions/checkout@<40-char sha> # v7.0.1
# A tag can be moved by whoever controls the action's repo; a commit SHA can't. Dependabot keeps the pins fresh.
set -euo pipefail
(( $# )) || { echo "usage: pin_actions.sh .github/workflows/*.yml" >&2; exit 2; }

resolve() {                                   # resolve OWNER/REPO MAJOR → "sha version"
    local repo=$1 major=$2 tags best sha
    tags=$(git ls-remote --tags "https://github.com/$repo" "refs/tags/$major*") || return 1
    # newest full release inside that major (v7 → v7.0.1); fall back to the bare tag itself
    best=$(grep -oE "refs/tags/${major}(\.[0-9]+)+$" <<< "$tags" | sed 's#refs/tags/##' | sort -V | tail -1)
    best=${best:-$major}
    # annotated tags appear twice; the "^{}" line is the commit the tag points to — prefer it
    sha=$(awk -v t="refs/tags/$best^{}" '$2 == t { print $1 }' <<< "$tags")
    [[ -n $sha ]] || sha=$(awk -v t="refs/tags/$best" '$2 == t { print $1 }' <<< "$tags")
    [[ -n $sha ]] || return 1
    printf '%s %s\n' "$sha" "$best"
}

for file in "$@"; do
    while IFS= read -r ref; do
        repo=${ref%@*} major=${ref#*@}
        repo_root=$(cut -d/ -f1-2 <<< "$repo")                 # owner/repo/path@v1 → owner/repo
        if read -r sha version < <(resolve "$repo_root" "$major"); then
            sed -i -E "s#uses: ${repo}@${major}([[:space:]]|\$).*#uses: ${repo}@${sha} \# ${version}#" "$file"
            echo "$file: $repo@$major → ${sha:0:12}… ($version)"
        else
            echo "$file: could not resolve $repo@$major" >&2
        fi
    done < <(grep -oE 'uses: [^ ./][^ ]*@v[0-9]+(\.[0-9]+)*' "$file" | sed 's/uses: //' | sort -u)
done
