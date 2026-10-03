#!/usr/bin/env bash
# revert-merge — reference solution (run in DIR/work). Shared history: add a NEW commit that undoes the change.
merge=$(git log --merges --format=%H -1 --grep='#42')
git show --stat "$merge" | head -8
git revert -m 1 --no-edit "$merge"                # -m 1: keep the main side (parent 1), undo what the merge brought in
git push origin main
git log --oneline -4
