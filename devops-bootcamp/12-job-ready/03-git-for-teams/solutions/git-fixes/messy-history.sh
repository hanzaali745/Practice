# messy-history — reference solution (run in DIR/work). Interactive alternative: git rebase -i main
# (mark commits "fixup"/"squash", reorder, "reword"). Here: the same result without an editor.
git switch feature/healthcheck
git reset --soft main                             # keep all changes, drop the 6 commits
git reset -q                                      # unstage, so we can build 2 commits by hand
git add healthcheck.sh healthcheck.conf
git commit -m "feat(health): add healthcheck script and config"
git add docs/
git commit -m "docs(health): document the healthcheck"
git log --oneline main..
git push --force-with-lease origin feature/healthcheck   # refuses if someone else pushed meanwhile
