#!/usr/bin/env bash
# install_into.sh LAB_REPO — copy this capstone pipeline into your lab repo (from Module 01) as one commit
#   ./install_into.sh ~/cicd-lab
set -euo pipefail
src=$(cd "$(dirname "$0")" && pwd)
repo=${1:?usage: install_into.sh LAB_REPO}
[[ -d $repo/.git ]] || { echo "$repo is not a git repository" >&2; exit 1; }

cp -r "$src/.github" "$src/deploy" "$src/argocd" "$repo/"
cp "$src/scripts/bump_image.sh" "$repo/scripts/"
cp "$src/act-event.json" "$repo/"
rm -rf "$repo/deploy/k8s"                      # replaced by deploy/base + deploy/overlays
cd "$repo"
git add -A
git commit -qm "CI/CD capstone: ci, delivery (staging → production), release, GitOps overlays"
echo "✅ committed in $repo — now set up the 'staging' and 'production' environments (README) and push"
