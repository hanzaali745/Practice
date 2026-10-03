# CI/CD Module 06 — Reusable Workflows & Custom Actions 🔴

## 🎯 Objectives
- Package repeated steps as a **composite action** with inputs and outputs
- Turn a whole job into a **reusable workflow** (`workflow_call`) and call it like a function
- Share actions and workflows across repositories, versioned and pinned
- Know the three kinds of actions (composite, JavaScript, Docker) and when to write each

## 🧠 Why DevOps engineers care
A platform team rarely owns one pipeline — it owns the *standard* pipeline for fifty services. Copy-pasting 200
lines of YAML into every repo means fifty places to fix every bug. Reusable workflows and actions let you write the
pipeline once, version it, and let every team call it in ten lines. This is "pipelines as a product".

---

## 📖 Lesson 6.1 — Composite actions

`.github/actions/setup-demo/action.yml`:
```yaml
name: Set up demo-app tooling
description: Install Python with pip caching and the dev requirements
inputs:
  python-version:
    required: false
    default: "3.12"
outputs:
  python-version:
    value: ${{ steps.py.outputs.python-version }}
runs:
  using: composite
  steps:
    - id: py
      uses: actions/setup-python@v7
      with:
        python-version: ${{ inputs.python-version }}
        cache: pip
    - shell: bash                       # required for run steps in composite actions
      run: pip install -r requirements-dev.txt
```
Use it (after `actions/checkout` — the action lives in the repo):
```yaml
      - uses: ./.github/actions/setup-demo
        with:
          python-version: "3.13"
```
Inside an action, `$GITHUB_ACTION_PATH` is the action's own folder — ship scripts next to `action.yml`
(see [`smoke-test`](solutions/.github/actions/smoke-test/)).

## 📖 Lesson 6.2 — Reusable workflows

```yaml
# .github/workflows/reusable-python-ci.yml
on:
  workflow_call:
    inputs:
      python-version: { type: string, default: "3.12" }
      tests: { type: string, default: tests/ }
    secrets:
      SONAR_TOKEN: { required: false }      # callers pass secrets explicitly (or `secrets: inherit`)
    outputs:
      python-version:
        value: ${{ jobs.test.outputs.python-version }}
jobs:
  test: ...
```
```yaml
# caller
jobs:
  python:
    strategy:
      matrix:
        python: ["3.12", "3.13"]
    uses: ./.github/workflows/reusable-python-ci.yml
    with:
      python-version: ${{ matrix.python }}
```
A calling job has `uses:` **instead of** `runs-on:` and `steps:`.

| | Composite action | Reusable workflow |
|--|------------------|-------------------|
| Replaces | some **steps** | whole **jobs** |
| Can have its own `runs-on`, services, environments, matrix | ❌ | ✅ |
| Shows up in logs as | one step (expandable) | separate jobs |
| Use for | "set up X", "deploy Y" building blocks | the standard pipeline per language/service |

## 📖 Lesson 6.3 — Sharing across repositories

```yaml
    uses: your-org/pipelines/.github/workflows/python-ci.yml@3d3c42e5aac5ba805825da76410c181273ba90b1  # v1.4.0
      - uses: your-org/actions/setup-demo@v1.4.0
```
Put shared workflows in one repo (e.g. `your-org/pipelines`), release them with tags, and pin callers to a SHA
(Module 05). For private repos, allow access in that repo's **Settings → Actions → General → Access**.

## 📖 Lesson 6.4 — JavaScript and Docker actions

| Kind | `runs.using` | Good for |
|------|--------------|----------|
| Composite | `composite` | gluing steps and scripts — **start here** |
| JavaScript | `node24` | fast, cross-platform logic using the `@actions/core` toolkit; needs a build step |
| Docker | `docker` | any language/tools, Linux runners only, slower to start |

Publishing an action to the Marketplace = a public repo with `action.yml` at the root plus releases.

## 📖 Lesson 6.5 — Testing it all locally

`act` runs composite actions and local reusable workflows. Two local limits worth knowing: `act` doesn't fill in
`job.services.<name>.ports`, and jobs from a matrix run on **one** machine, so fixed host ports (like `6379:6379`)
collide. That's why the solution keeps service containers out of the reusable matrix workflow and runs the
integration job once.

---

## ⚠️ Common mistakes
- Forgetting `shell:` on `run` steps in composite actions
- Using a local action before `actions/checkout` (the files aren't there yet)
- Calling another repo's workflow on `@main` — every change they push runs in your pipeline instantly
- Passing secrets with `secrets: inherit` everywhere (pass only what's needed)
- Building a JavaScript action when a 10-line composite action would do

---

## 🧪 Labs
Solutions: [`solutions/.github/`](solutions/.github/) — copy the whole `.github` folder into your lab repo.

### Lab 1 ⭐ — Composite setup action
Write `setup-demo` (Python + pip cache + dev requirements, with an input and an output) and use it in your
Module 03 workflow, replacing the repeated steps in every job.

### Lab 2 ⭐⭐ — Reusable workflow
Move lint + tests into `reusable-python-ci.yml` with `python-version` and `tests` inputs and a
`python-version` output. Call it from `ci-caller.yml` with a matrix of 3.12 and 3.13, and read the output in a
later job.

### Lab 3 ⭐⭐ — Across repositories
Create a second repo `pipelines`, move the reusable workflow there, tag `v1.0.0`, and call it from your lab repo
pinned to the SHA. Change the workflow, tag `v1.1.0`, and update the pin.

### Lab 4 ⭐⭐⭐ — Your own action
Write `smoke-test`: inputs `url` and `version`, output `result`, with the script shipped next to `action.yml`
and called through `$GITHUB_ACTION_PATH`. Use it after starting the app. Add a README for the action listing
inputs and outputs.

---

## ✅ Checkpoint
- [ ] I can write composite actions with inputs, outputs and bundled scripts
- [ ] I can write and call reusable workflows with inputs, secrets and outputs
- [ ] I share pipelines across repos with tags and pinned SHAs
- [ ] I know when to choose a composite, JavaScript or Docker action

👉 Next: [Module 07 — Deployment Pipelines & GitOps](../07-deployment-and-gitops/README.md)
