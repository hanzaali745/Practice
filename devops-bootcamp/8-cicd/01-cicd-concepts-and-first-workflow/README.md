# CI/CD Module 01 — CI/CD Concepts & Your First Workflow 🟢

## 🎯 Objectives
- Explain continuous integration, continuous delivery and continuous deployment
- Name the parts of GitHub Actions: workflow, event, job, step, action, runner
- Create your own lab repository on GitHub
- Write and run your first workflow — on GitHub **and** on your laptop with `act`
- Read a workflow run: logs, annotations, re-runs

## 🧠 Why DevOps engineers care
Every change a developer makes should be tested, built and shipped **automatically**, the same way every time.
That pipeline is usually owned by the DevOps team. In Phases 1–7 you ran tests, builds and deploys by hand —
now you teach a robot to do it on every push. "Can you build a pipeline?" is in almost every DevOps interview.

---

## 📖 Lesson 1.1 — CI, CD and CD

```
 developer pushes ─► CI: lint · test · build ─► artifact (image) ─► CD: deploy staging ─► deploy production
                     └──── every commit ────┘                        └──────── automatically or with approval ──┘
```

| Term | Meaning |
|------|---------|
| **Continuous Integration (CI)** | every push is automatically linted, tested and built; broken code is caught in minutes |
| **Continuous Delivery** | every passing build *could* go to production — a human presses the button |
| **Continuous Deployment** | every passing build *does* go to production, no human step |
| **Pipeline** | the ordered stages a change goes through |
| **Artifact** | what the pipeline produces and deploys: an image, a package, a zip |

Golden rules: **build once, deploy the same artifact everywhere**; **fail fast** (cheap checks first);
**everything as code** (the pipeline lives in the repo, reviewed like any change).

## 📖 Lesson 1.2 — GitHub Actions vocabulary

```
.github/workflows/ci.yml   ← a WORKFLOW (one YAML file)
 on: push                  ← the EVENT that starts it
 jobs:
   test:                   ← a JOB: runs on one RUNNER (a fresh VM), jobs run in parallel by default
     runs-on: ubuntu-latest
     steps:                ← STEPS run in order, in the same VM, sharing files
       - uses: actions/checkout@v7      ← an ACTION: a reusable step someone published
       - run: pytest                    ← a shell command
```
Other CI systems use the same ideas with different words: GitLab CI (`.gitlab-ci.yml`, stages, jobs, runners),
Jenkins (`Jenkinsfile`, stages, agents), Azure Pipelines, CircleCI. Learn one well and the rest are easy — the
capstone shows the same pipeline in GitLab CI and Jenkins.

## 📖 Lesson 1.3 — Your lab repository

Workflows only run from `.github/workflows/` at the **root** of a GitHub repository, so you practise in a new
repo of your own (public repos get unlimited free Actions minutes):
```bash
cd ~/Practice/devops-bootcamp/8-cicd
./new_lab_repo.sh ~/cicd-lab
cd ~/cicd-lab && ls
```
On github.com: **New repository** → name `cicd-lab` → **no** README → Create. Then:
```bash
git remote add origin git@github.com:<you>/cicd-lab.git
git push -u origin main
```
What's inside: [`lab-repo/README.md`](../lab-repo/README.md) — demo-app, tests, Dockerfile, Kubernetes manifests.

## 📖 Lesson 1.4 — Your first workflow

`.github/workflows/hello.yml`:
```yaml
name: hello
on:
  push:
  workflow_dispatch:          # "Run workflow" button
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Say hello
        run: |
          echo "Hello from GitHub Actions!"
          echo "Commit: $GITHUB_SHA by ${{ github.actor }}"
```
```bash
git add .github/workflows/hello.yml && git commit -m "Add hello workflow" && git push
```
On GitHub: **Actions** tab → the run → the job → expand each step. A red ❌ step shows the error; **Re-run jobs**
retries. The commit gets a ✅/❌ badge — that's what pull requests show to reviewers.

Two ways to write values:
- `$GITHUB_SHA` — an environment variable, read by the **shell** on the runner
- `${{ github.sha }}` — an **expression**, filled in by GitHub *before* the step runs

## 📖 Lesson 1.5 — Run workflows on your laptop with `act`

Pushing to test every typo is slow. [`act`](https://github.com/nektos/act) runs your workflows in Docker locally
(installed in [setup part 3](../../00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md)):
```bash
cd ~/cicd-lab
act -l                                   # list jobs
act push                                 # simulate a push
act -j test                              # one job
```
The first run asks which image size to use — the solution script [`act_local.sh`](solutions/act_local.sh) picks a
GitHub-like image for you. `act` is very good but not identical to GitHub (no real `GITHUB_TOKEN`, some actions
behave differently), so the real proof is always a green run on GitHub.

Catch mistakes before running anything with **actionlint**:
```bash
actionlint                               # checks every file in .github/workflows/
```

## 📖 Lesson 1.6 — The smallest useful CI

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-python@v7
        with:
          python-version: "3.12"
      - run: pip install -r requirements-dev.txt
      - run: ruff check .
      - run: python3 -m pytest -q
```
Make a branch, break a test on purpose, open a pull request: the PR shows a red ❌ before anyone reviews it.
That's CI doing its job.

---

## ⚠️ Common mistakes
- Workflow file not in `.github/workflows/` at the repo root (so it never runs)
- YAML indentation errors → run `actionlint` before pushing
- Mixing up `${{ }}` (GitHub fills it in) and `$VAR` (the shell reads it)
- Testing on GitHub by pushing 20 "fix ci" commits → use `act` and `actionlint` first
- Floating `@main` versions of actions (use a release tag like `@v4` — Module 05 goes further)

---

## 🧪 Labs
Solutions: [`solutions/workflows/`](solutions/workflows/) — copy into `~/cicd-lab/.github/workflows/`.

### Lab 1 ⭐ — Hello, Actions
Create your lab repo, add `hello.yml`, push, and find your message in the logs. Add a step that prints the runner's
OS, Python and Docker versions. Trigger it again with the **Run workflow** button.

### Lab 2 ⭐ — Local runs
Install `act` and `actionlint`. Run `act -l` and `act push` in your lab repo. Introduce a YAML mistake and see
`actionlint` catch it.

### Lab 3 ⭐⭐ — First CI
Add `ci.yml` (lint + unit tests). Push to `main`: green. Create a branch that breaks a test, open a pull request,
and screenshot the red check. Fix it on the branch and watch the PR turn green.

### Lab 4 ⭐⭐ — Protect main
In the repo **Settings → Branches → Add rule** for `main`: require a pull request and require the `test` check to
pass. Try to push directly to `main` — it's refused. From now on every change goes through a PR.

---

## ✅ Checkpoint
- [ ] I can explain CI, continuous delivery and continuous deployment
- [ ] I know workflow, event, job, step, action and runner
- [ ] I can write a workflow, run it on GitHub and locally with act, and lint it with actionlint
- [ ] My `main` branch only accepts pull requests with a green CI check

👉 Next: [Module 02 — Workflow Syntax in Depth](../02-workflow-syntax/README.md)
