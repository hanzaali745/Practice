# Job-ready Module 03 — Git for Teams 🟡

## 🎯 Objectives
- Work the way teams do: short-lived branches, pull requests, reviews, protected `main`
- Choose between merge, rebase and squash — and resolve conflicts calmly
- Rewrite **your own** history before review (squash, reword) and never rewrite **shared** history
- Undo anything: `revert`, `reset`, `reflog`, `restore`, and find bugs with `bisect`
- Ship hotfixes with `cherry-pick` and release with annotated tags
- Keep secrets and junk out of the repo with hooks — and clean up properly when a secret leaks

## 🧠 Why DevOps engineers care
You've used Git every day of this bootcamp, mostly alone. At work, ten people push to the same repository, CI runs on
every branch, and infrastructure changes go through pull requests (GitOps!). Being the person who can untangle a bad
rebase, recover "lost" work or purge a leaked key — without panicking — earns trust quickly.

---

## 🧪 The Git lab
```bash
cd ~/Practice/devops-bootcamp/12-job-ready/03-git-for-teams
./git-lab.sh list                    # 7 team situations
./git-lab.sh new conflict            # creates ~/git-lab/conflict/{origin.git, work}
cd ~/git-lab/conflict/work           # YOUR clone: solve it here
./git-lab.sh check conflict          # (from this folder) solved the way a team needs it?
```
Each scenario has a shared remote (`origin.git`, playing GitHub) with commits from teammates. Delete a scenario folder to
start it again. Reference solutions: [`solutions/git-fixes/`](solutions/git-fixes/).

---

## 📖 Lesson 3.1 — How teams use Git

| Workflow | How | Fits |
|----------|-----|------|
| **Trunk-based** | tiny branches (hours–days) merged to `main` behind CI; feature flags hide unfinished work | most DevOps/cloud teams, continuous delivery |
| **GitHub flow** | branch → PR → review → merge to `main` → deploy | the common default |
| **GitFlow** | `develop`, `release/*`, `hotfix/*` branches | versioned products with slow release cycles |

The rules that make any of them work: protect `main` (PRs only, required reviews and checks — Phase 8, Module 01);
keep PRs small (<400 lines is reviewable); one logical change per commit; branch names that say what
(`feat/redis-cache`, `fix/login-timeout`); delete merged branches.

**Commit messages** — [Conventional Commits](https://www.conventionalcommits.org/) are common because tools read them
(changelogs, version bumps):
```
feat(cache): add Redis TTL per key          ← type(scope): what, in the imperative, ≤ 72 chars

Sessions stayed in Redis forever and memory grew 2 GB/week.   ← why (the diff already says what)
Refs: OPS-1234
```
Types: `feat`, `fix`, `docs`, `refactor`, `test`, `ci`, `build`, `chore`, `perf`; `feat!:` = breaking change.

## 📖 Lesson 3.2 — Merge, rebase, squash

```
merge:   A---B---C---M      keeps every commit + a merge commit: true history, noisier graph
              \     /
               D---E
rebase:  A---B---C---D'--E'  replays your commits on top: linear, but NEW commits (new SHAs)
squash:  A---B---C---S       the whole branch becomes one commit on main (common "Squash and merge" button)
```
```bash
git fetch origin
git rebase origin/main            # update your branch (or: git pull --rebase); conflicts are solved commit by commit
git rebase --continue / --skip / --abort
git merge --no-ff feature/x       # a merge commit even when fast-forward was possible
git config --global pull.rebase true      # never create accidental "Merge branch 'main' of ..." commits
git config --global rerere.enabled true   # remember how you resolved a conflict, reuse it next time
```
**The golden rule:** rebase and rewrite only commits nobody else has. Once pushed to a shared branch, history is
shared — fix it with new commits (`revert`), not by rewriting.

## 📖 Lesson 3.3 — Conflicts without fear

```bash
git status                         # "both modified" files
git diff                           # the conflict markers, in context
git checkout --ours file / --theirs file   # take one side entirely (in a rebase, "ours" is the branch you're rebasing ONTO)
git mergetool                      # a 3-way tool (vimdiff, meld, VS Code)
git log --merge -p file            # which commits on each side touched it
```
Resolve by **understanding both changes**, not by picking a side: the right result often combines them. Then run the
tests, `git add`, and continue. No `<<<<<<<` markers may survive — the pre-commit framework can block them.

## 📖 Lesson 3.4 — Clean history before review

```bash
git commit --fixup <sha>                   # "this fixes that commit"...
git rebase -i --autosquash main            # ...and autosquash folds them in
git rebase -i main                         # pick / reword / squash / fixup / drop / reorder
git reset --soft main                      # or: keep the changes, drop the commits, re-commit cleanly
git commit --amend                         # change the last commit (message or content)
git push --force-with-lease                # update YOUR pushed branch; refuses if someone else pushed meanwhile
```
Never `git push --force` (without lease) to a branch others use, and never to `main`.

## 📖 Lesson 3.5 — Undo anything

| Situation | Command |
|-----------|---------|
| Discard changes to a file | `git restore file` |
| Unstage | `git restore --staged file` |
| Undo a pushed commit (shared) | `git revert <sha>` — a new commit that does the opposite |
| Undo a pushed **merge** | `git revert -m 1 <merge-sha>` (1 = keep the main side) |
| Move my branch back (local only) | `git reset --soft/--mixed/--hard <sha>` |
| "I lost commits!" | `git reflog` — every place HEAD has been (~90 days); `git branch rescue <sha>` |
| Which commit broke it? | `git bisect start BAD GOOD` → `git bisect run ./test.sh` |
| Who changed this line, and why? | `git blame -w file`, then `git show <sha>`; `git log -S 'text'` finds when text appeared |

`git stash push -m "msg"` / `git stash pop` parks unfinished work; `git worktree add ../hotfix release/1.4` gives you a
second working folder without stashing.

## 📖 Lesson 3.6 — Releases, tags and hotfixes

```bash
git tag -a v1.4.1 -m "1.4.1: escape user input"   # annotated: author, date, message — use these for releases
git push origin v1.4.1                            # tags aren't pushed by default
git describe --tags                               # v1.4.1-3-gabc1234 → 3 commits after v1.4.1
git cherry-pick -x <sha>                          # copy one commit to another branch, noting where it came from
```
Semantic Versioning: `MAJOR.MINOR.PATCH` — breaking change . new feature . bug fix. In Phase 8 a pushed `v*` tag
triggered the release workflow.

## 📖 Lesson 3.7 — Keep bad things out (and clean up when they get in)

- **`.gitignore`** from day one: `.env`, `*.tfstate`, `.terraform/`, `__pycache__/`, `node_modules/`, keys.
- **Hooks**: [`solutions/hooks/pre-commit`](solutions/hooks/pre-commit) blocks secrets, key files and huge files on your
  machine; [`solutions/.pre-commit-config.yaml`](solutions/.pre-commit-config.yaml) shares hooks (including gitleaks)
  with the whole team — run `pre-commit run --all-files` in CI too, because local hooks can be skipped.
- **Large files**: Git LFS, or keep them out (artifacts belong in a registry or S3).
- **Signed commits**: `git config commit.gpgsign true` with an SSH or GPG key; GitHub shows "Verified".

**A secret was pushed. In this order:**
1. **Rotate it immediately** (revoke the key, create a new one). Bots scan public GitHub in minutes; rewriting history
   does **not** un-leak it.
2. Check the provider's logs for misuse (CloudTrail, Phase 11).
3. Remove it from history: `git filter-repo --invert-paths --path .env` in a fresh clone; force-push branches **and**
   tags; everyone re-clones; ask GitHub support to purge cached views.
4. Add the prevention: `.gitignore`, pre-commit hooks, secret scanning on the repository.

---

## ⚠️ Common mistakes
- Long-lived branches that drift for weeks and end in conflict hell
- `git push --force` to a shared branch — destroying teammates' work
- Rebasing a branch someone else has already pulled
- "Fixing" a pushed bad merge with `reset` + force-push instead of `revert`
- Commit messages like "fix", "wip", "asdf"; one commit mixing a refactor, a feature and a formatting change
- Removing a leaked secret from history but not rotating it

---

## 🧪 Labs
Run each with `./git-lab.sh new NAME`, solve it in `~/git-lab/NAME/work`, then `./git-lab.sh check NAME`.

### Lab 1 ⭐ — Rebase through a conflict
`conflict` — update your branch onto a teammate's change, combine both, push.

### Lab 2 ⭐⭐ — Find the bad commit
`bisect` — 30 commits, one regression. Use `git bisect run`.

### Lab 3 ⭐⭐ — Nothing is lost
`lost-work` — a `reset --hard` and a deleted branch. The reflog remembers.

### Lab 4 ⭐⭐ — Ready for review
`messy-history` — six messy commits become two clean ones; push safely.

### Lab 5 ⭐⭐ — Undo in production
`revert-merge` — undo a merged PR without rewriting shared history.

### Lab 6 ⭐⭐ — The hotfix
`hotfix` — one fix to the release branch, tagged and pushed.

### Lab 7 ⭐⭐⭐ — The leaked key
`leaked-secret` — purge it from every branch and tag (`pip install -r ../../requirements-platform.txt` gives you
`git-filter-repo`), and make sure it can't happen again.

### Lab 8 ⭐⭐ — Guard rails
Install [`solutions/hooks/pre-commit`](solutions/hooks/pre-commit) in your lab repo from Phase 8 and prove it blocks a
fake AWS key, a `.env` file and a 2 MB file. Then set up the shared version: `pre-commit install` with
[`.pre-commit-config.yaml`](solutions/.pre-commit-config.yaml), and add `pre-commit run --all-files` to your CI workflow.

---

## ✅ Checkpoint
- [ ] I can explain trunk-based development, PR etiquette and Conventional Commits
- [ ] I can rebase through conflicts and know when to merge, rebase or squash
- [ ] I clean up my own history and never rewrite shared history
- [ ] I can recover lost work with the reflog and find regressions with bisect
- [ ] I can revert a merge, cherry-pick a hotfix and tag a release
- [ ] I know the four steps after a secret leak — rotation first
- [ ] All seven `git-lab.sh` scenarios pass `check`

👉 Next: [Module 04 — Incident Practice](../04-incident-practice/README.md)
