#!/usr/bin/env bash
# lost-work — reference solution (run in DIR/work). The reflog remembers where HEAD has been for ~90 days.
git reflog | head -12
b=$(git log -g --format='%H %s' | grep -m1 ' feat: important change B$' | cut -d' ' -f1)
git reset --hard "$b"                             # main is back at B (and A is its parent)
r=$(git log -g --format='%H %s' | grep -m1 ' feat(report): section 3$' | cut -d' ' -f1)
git branch feature/report "$r"                    # a branch is just a name for a commit: recreate it
git log --oneline main -3; git log --oneline feature/report -4
