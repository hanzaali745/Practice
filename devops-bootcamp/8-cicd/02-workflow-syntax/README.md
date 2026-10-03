# CI/CD Module 02 — Workflow Syntax in Depth 🟢

## 🎯 Objectives
- Choose the right **events** and filter them by branch, path and type
- Add manual runs with typed **inputs**, and scheduled runs with **cron**
- Chain **jobs** with `needs`, pass **outputs** between them, and run them conditionally with `if`
- Use **expressions and contexts** (`github`, `env`, `inputs`, `needs`, `matrix`)
- Test many versions at once with a **matrix**
- Control cost and noise with `concurrency`, `timeout-minutes` and job summaries

## 🧠 Why DevOps engineers care
Real pipelines are not one job. They test on several versions, skip work when only docs changed, release only on
tags, and never run two deploys at once. These keywords are the building blocks of every pipeline you'll write —
in GitHub Actions and, with different names, in every other CI system.

---

## 📖 Lesson 2.1 — Events and filters

```yaml
on:
  push:
    branches: [main, "release/**"]
    tags: ["v*"]
    paths: ["app/**", "tests/**"]          # only when these files change (paths-ignore: the opposite)
  pull_request:
    types: [opened, synchronize, reopened]  # synchronize = new commits pushed to the PR
  schedule:
    - cron: "17 3 * * 1"                    # UTC! Mondays 03:17
  workflow_dispatch:                        # manual "Run workflow" button
    inputs:
      environment:
        type: choice
        options: [staging, production]
      dry_run:
        type: boolean
        default: true
```
Other useful events: `release`, `workflow_run` (after another workflow), `workflow_call` (reusable — Module 06).

## 📖 Lesson 2.2 — Jobs, `needs` and `if`

```
          ┌── test ──┐
version ──┤          ├── release (only on tags) ── summary (always)
          └── lint ──┘
```
```yaml
jobs:
  version: ...
  test:
    needs: version                         # waits, and can read version's outputs
  lint:
    needs: version                         # test and lint run in parallel
  release:
    needs: [version, test]
    if: needs.version.outputs.is_release == 'true'
  summary:
    needs: [version, test, lint, release]
    if: always()                           # also: success() (default), failure(), cancelled()
```
Step-level `if:` works the same way, e.g. `if: failure()` for a "notify on failure" step.

## 📖 Lesson 2.3 — Outputs: passing values between steps and jobs

```yaml
  version:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.calc.outputs.version }}        # 3) expose it as a job output
    steps:
      - id: calc                                         # 1) give the step an id
        run: echo "version=1.4.0" >> "$GITHUB_OUTPUT"    # 2) write key=value to $GITHUB_OUTPUT
  test:
    needs: version
    steps:
      - run: echo "testing ${{ needs.version.outputs.version }}"   # 4) read it
```
Special files on the runner: `$GITHUB_OUTPUT` (outputs), `$GITHUB_ENV` (env vars for later steps),
`$GITHUB_STEP_SUMMARY` (Markdown shown on the run page), `$GITHUB_PATH` (add to PATH).

## 📖 Lesson 2.4 — Expressions and contexts

```yaml
${{ github.ref_name }}        ${{ github.sha }}            ${{ github.event_name }}   ${{ github.actor }}
${{ env.APP_NAME }}           ${{ inputs.environment }}    ${{ needs.build.result }}  ${{ matrix.python }}
${{ secrets.TOKEN }}          ${{ vars.REGION }}           ${{ runner.os }}           ${{ steps.calc.outputs.x }}
${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}   # a "ternary"
${{ contains(github.event.head_commit.message, '[skip tests]') }}
${{ startsWith(github.ref, 'refs/tags/v') }}   ${{ toJSON(github.event) }}   ${{ hashFiles('**/requirements*.txt') }}
```
Pass expressions into `run:` through **`env:`** rather than pasting them into the script — it's safer
(Module 05 explains script injection) and easier to read:
```yaml
      - env:
          REF: ${{ github.ref_name }}
        run: echo "branch is $REF"
```

## 📖 Lesson 2.5 — Matrix builds

```yaml
    strategy:
      fail-fast: false
      matrix:
        python: ["3.11", "3.12", "3.13"]
        os: [ubuntu-latest]
        include:
          - python: "3.12"
            coverage: true                 # add a variable to one combination
        exclude: []                        # drop combinations
    steps:
      - uses: actions/setup-python@v7
        with:
          python-version: ${{ matrix.python }}
```
3 Pythons × 1 OS = 3 parallel jobs. Name them so the PR checks are readable: `name: test (py${{ matrix.python }})`.

## 📖 Lesson 2.6 — Staying fast and cheap

```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true                 # new push cancels the old run (never use this for production deploys!)
jobs:
  test:
    timeout-minutes: 10                    # default is 360 minutes
defaults:
  run:
    shell: bash
```
Use `paths` filters so documentation changes don't run the full test suite, and put cheap checks (lint) before
expensive ones (image builds, end-to-end tests).

---

## ⚠️ Common mistakes
- Forgetting `id:` on a step and then reading `steps.<id>.outputs`
- `if: needs.x.outputs.flag == true` — outputs are **strings**: compare with `'true'`
- Cron in local time (it's UTC) and expecting it to run on time (scheduled runs can be delayed)
- `cancel-in-progress: true` on deploy workflows → a half-finished deploy
- A summary/notify job without `if: always()` never runs after a failure — exactly when you need it

---

## 🧪 Labs
Solutions: [`solutions/workflows/`](solutions/workflows/). Test locally first: `act -l`, `act push`, `actionlint`.

### Lab 1 ⭐ — Triggers
Write `triggers.yml` that runs on pushes to `main` and `release/**` only when `app/` or `tests/` change, on pull
requests, every Monday at 03:17 UTC, and manually with a `choice` input (`staging`/`production`) and a boolean
`dry_run`. Add `concurrency` and a timeout. Run it manually from the Actions tab with different inputs.

### Lab 2 ⭐⭐ — A job graph
Write `jobs-and-outputs.yml`: `version` → (`test` ∥ `lint`) → `release` → `summary`. `version` computes
`0.0.0-<short sha>` normally and `X.Y.Z` for a `vX.Y.Z` tag; `release` runs only for tags; `summary` always runs
and writes a Markdown table of job results to the job summary.
Test the tag path locally: `act push -e tag-event.json` with `{"ref": "refs/tags/v1.2.0", "ref_type": "tag"}`.

### Lab 3 ⭐⭐ — Matrix
Run the unit tests on Python 3.11, 3.12 and 3.13 with `fail-fast: false`; add a `coverage` flag to the 3.12
combination only. Make one version fail on purpose (e.g. use a 3.13-only feature) and see the other two still finish.

### Lab 4 ⭐⭐⭐ — Release on tag
Push a tag: `git tag v0.1.0 && git push origin v0.1.0`. Confirm the `release` job runs and the summary shows
`0.1.0`. Then add a step-level `if: failure()` "notify" step that prints which job failed.

---

## ✅ Checkpoint
- [ ] I can filter events by branch, tag, path and type, and add inputs and schedules
- [ ] I can chain jobs with `needs`, pass outputs and use `if` with `always()`/`failure()`
- [ ] I pass expressions to scripts through `env:` and know the main contexts
- [ ] I can write a matrix and use concurrency, timeouts and job summaries

👉 Next: [Module 03 — Testing & Quality Gates in CI](../03-testing-in-ci/README.md)
