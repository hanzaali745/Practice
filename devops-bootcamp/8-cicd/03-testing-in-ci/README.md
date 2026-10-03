# CI/CD Module 03 — Testing & Quality Gates in CI 🟡

## 🎯 Objectives
- Build a CI pipeline in stages: lint → unit tests → integration tests → image build + smoke test
- Lint Python, shell scripts and Dockerfiles, with annotations on the pull request
- Run integration tests against real dependencies with **service containers**
- Speed up runs with **caching**, and keep reports with **artifacts**
- Give branch protection one stable required check

## 🧠 Why DevOps engineers care
CI is only as good as what it checks. A pipeline that runs one unit test lets broken Dockerfiles, bad shell scripts
and integration bugs through. A good quality gate catches them in minutes, on the pull request, before a human even
starts reviewing — and it stays fast enough that developers don't try to skip it.

---

## 📖 Lesson 3.1 — Pipeline shape

```
         ┌── unit ─────────┐
 lint ──►┤                 ├──► image (build + smoke test) ──► ci-ok
         └── integration ──┘
  ~30 s      ~1 min                     ~2 min
```
Cheapest checks first (fail fast), independent jobs in parallel, expensive work last. Everything you learned to
test by hand in Phases 1–4 becomes a job.

## 📖 Lesson 3.2 — Linting everything

```yaml
      - name: Python lint
        run: ruff check --output-format=github .      # inline annotations on the PR diff
      - name: Shell lint
        run: docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:v0.11.0 scripts/*.sh
      - name: Dockerfile lint
        run: docker run --rm -i hadolint/hadolint:v2.15.1 < Dockerfile
```
Running linters from **pinned container images** gives the same version on GitHub, on `act` and on your laptop.

## 📖 Lesson 3.3 — Service containers

```yaml
  integration:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis:7-alpine
        ports: ["6379:6379"]
        options: >-
          --health-cmd "redis-cli ping" --health-interval 2s --health-retries 15
    env:
      REDIS_HOST: 127.0.0.1
    steps:
      - run: python3 -m pytest -q tests/test_integration.py
```
GitHub starts Redis, waits until its healthcheck passes, then runs your steps. Postgres, MySQL, Elasticsearch —
same pattern. (If your job itself runs in a `container:`, use the service **name** `redis` as the host instead.)

## 📖 Lesson 3.4 — Caching and artifacts

```yaml
      - uses: actions/setup-python@v7
        with:
          python-version: "3.12"
          cache: pip                                  # restores ~/.cache/pip; key = hash of requirements
          cache-dependency-path: requirements-dev.txt
```
For anything else, `actions/cache@v6` with a `key:` built from `hashFiles(...)`.

**Artifacts** are files a job keeps after it finishes — test reports, coverage, built packages:
```yaml
      - run: python3 -m pytest -q --junitxml=reports/unit.xml
      - uses: actions/upload-artifact@v7
        if: always()                                  # most useful when tests FAIL
        with:
          name: unit-test-report
          path: reports/
          retention-days: 7
```
Running locally with `act`? It sets the environment variable `ACT=true`, so you can skip steps that only make
sense on GitHub: `if: always() && !env.ACT` (the solution does this for the upload).

Cache = speed (may disappear any time). Artifact = output (download it from the run page, or in a later job with
`actions/download-artifact@v8`).

## 📖 Lesson 3.5 — Build and smoke-test the image

```yaml
      - run: docker build -t demo-app:ci --build-arg VERSION="ci-${GITHUB_SHA::7}" .
      - run: |
          docker run -d --name app -p 8000:8000 demo-app:ci
          scripts/smoke_test.sh http://127.0.0.1:8000 "ci-${GITHUB_SHA::7}"
      - if: failure()
        run: docker logs app
```
Unit tests prove the code works; the smoke test proves the **image** works — right user, right port, right command.

## 📖 Lesson 3.6 — One required check

Branch protection needs check **names**. With a matrix or many jobs those names change, so add a gate job:
```yaml
  ci-ok:
    needs: [lint, unit, integration, image]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - env:
          RESULTS: ${{ join(needs.*.result, ' ') }}
        run: for r in $RESULTS; do [[ $r == success ]] || exit 1; done
```
Then require only `ci-ok` in **Settings → Branches**. (`if: always()` matters: a skipped gate counts as passing!)

---

## ⚠️ Common mistakes
- Only unit tests in CI — Dockerfile and shell bugs slip through
- No `if: always()` on report uploads → no report exactly when tests fail
- Caching things that should be rebuilt (or never invalidating a cache key)
- Integration tests that depend on an external shared server → flaky, slow, unsafe
- Requiring every matrix job by name in branch protection → renaming one breaks every PR

---

## 🧪 Labs
Solution: [`solutions/workflows/ci.yml`](solutions/workflows/ci.yml) — the whole pipeline (it runs green with `act`).

### Lab 1 ⭐ — Lint stage
Add a `lint` job with ruff (GitHub annotation format), shellcheck and hadolint. Introduce one problem of each kind
in a pull request and find the annotations on the **Files changed** tab.

### Lab 2 ⭐⭐ — Tests with reports and cache
Add a `unit` job with pip caching and a JUnit report uploaded as an artifact even on failure. Compare the run time
of the setup step before and after the cache is warm.

### Lab 3 ⭐⭐ — Integration with a service container
Add an `integration` job with a Redis service and `REDIS_HOST`. Prove it's real: change the test to expect
`"backend": "memory"` and watch it fail.

### Lab 4 ⭐⭐⭐ — Image smoke test and the gate
Add the `image` job (build, run, `smoke_test.sh`, logs on failure, cleanup) and the `ci-ok` gate. Make `ci-ok` the
only required check on `main`. Break the Dockerfile (`USER root` is fine; a wrong `CMD` is not) and confirm the PR
is blocked.

---

## ✅ Checkpoint
- [ ] My pipeline runs lint, unit, integration and image checks in a sensible order
- [ ] I can use service containers, caches and artifacts
- [ ] I smoke-test the built image, not just the code
- [ ] My branch protection requires one stable gate check

👉 Next: [Module 04 — Building & Publishing Images](../04-building-images/README.md)
