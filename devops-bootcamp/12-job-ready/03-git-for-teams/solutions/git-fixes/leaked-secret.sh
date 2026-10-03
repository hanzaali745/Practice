# leaked-secret — reference solution (run in DIR/work). Needs git-filter-repo (pip install git-filter-repo).
# 0. FIRST rotate the key in AWS (deactivate + delete it): rewriting history doesn't un-leak it.
cd .. || exit 1
git clone -q --no-local origin.git cleaned        # filter-repo insists on a fresh clone
cd cleaned || exit 1
git fetch -q origin '+refs/heads/*:refs/heads/*' 2> /dev/null || true   # every branch locally
git filter-repo --invert-paths --path .env        # .env vanishes from every commit; tags are rewritten too
git log --all --oneline -- .env                   # nothing
echo ".env" >> .gitignore
git add .gitignore && git commit -q -m "chore: never commit .env files"
git remote add origin ../origin.git               # filter-repo removes the remote on purpose
git push -q --force origin --all
git push -q --force origin --tags
# then: everyone re-clones (old clones still contain the secret), and ask GitHub support to purge cached views
