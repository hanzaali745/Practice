#!/usr/bin/env bash
# new_lab_repo.sh DEST — create your own CI/CD practice repository from lab-repo/
set -euo pipefail
dest=${1:?usage: new_lab_repo.sh DEST   (e.g. ~/cicd-lab)}
src="$(cd "$(dirname "$0")" && pwd)/lab-repo"

[[ -e $dest ]] && { echo "ERROR: $dest already exists" >&2; exit 1; }
cp -r "$src" "$dest"
cd "$dest"
mkdir -p .github/workflows
git init -q -b main
git add -A
git commit -q -m "Start the CI/CD lab from the bootcamp starter"
echo "✅ created $dest ($(git rev-parse --short HEAD))"
echo "Next: create an empty GitHub repo, then:"
echo "  git remote add origin git@github.com:<you>/$(basename "$dest").git && git push -u origin main"
