# hotfix — reference solution (run in DIR/work)
fix=$(git log origin/main --format=%H --grep='^fix: escape user input')
git switch release/1.4                            # creates the local branch from origin/release/1.4
git cherry-pick -x "$fix"                         # -x adds "(cherry picked from commit ...)" to the message
git tag -a v1.4.1 -m "1.4.1: escape user input in greeting"
git push origin release/1.4 v1.4.1
git log --oneline -3
