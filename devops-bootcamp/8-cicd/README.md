# 🔁 Phase 8: CI/CD

> **Before you start:** finish Phases 4–7 and install `act`, `actionlint` and the GitHub CLI
> ([Part 3 of the Ubuntu setup](../00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md)).
> **It's free:** you practise in your own public GitHub repository (unlimited Actions minutes for public repos),
> created from the [lab repo](lab-repo/README.md) — demo-app, tests, Dockerfile and Kubernetes manifests.
> Most workflows also run on your laptop with `act`.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [CI/CD Concepts & Your First Workflow](01-cicd-concepts-and-first-workflow/README.md) | 🟢 | CI vs CD, workflow anatomy, run locally with act, protect main |
| 02 | [Workflow Syntax in Depth](02-workflow-syntax/README.md) | 🟢 | events, filters, inputs, needs, outputs, expressions, matrix |
| 03 | [Testing & Quality Gates in CI](03-testing-in-ci/README.md) | 🟡 | linters, service containers, caches, artifacts, a gate check |
| 04 | [Building & Publishing Images](04-building-images/README.md) | 🟡 | GHCR, tags, multi-arch, scanning, signing, SBOM, provenance |
| 05 | [Secrets, Environments & Pipeline Security](05-secrets-and-security/README.md) | 🔴 | approvals, least privilege, OIDC, injection, pinning, zizmor |
| 06 | [Reusable Workflows & Custom Actions](06-reusable-workflows-and-actions/README.md) | 🔴 | composite actions, `workflow_call`, sharing across repos |
| 07 | [Deployment Pipelines & GitOps](07-deployment-and-gitops/README.md) | 🔴 | e2e on kind, blue/green, Argo CD, releases |
| 08 | [CI/CD Capstone](08-capstone/README.md) | 🏆 | PR → signed image → staging → approved production, via GitOps |

## GitHub Actions cheat sheet

```yaml
on: { push: { branches: [main], paths: ["app/**"] }, pull_request: {}, workflow_dispatch: {}, workflow_call: {} }
permissions: {}                                   # then per job: contents: read, packages: write, id-token: write
concurrency: { group: "x-${{ github.ref }}", cancel-in-progress: true }
jobs:
  build:
    needs: test                                   # if: always() | failure() | github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    timeout-minutes: 10
    environment: production                       # approvals + environment secrets
    strategy: { fail-fast: false, matrix: { python: ["3.12", "3.13"] } }
    services: { redis: { image: "redis:7-alpine", ports: ["6379:6379"] } }
    outputs: { tag: "${{ steps.v.outputs.tag }}" }
    steps:
      - uses: actions/checkout@<sha> # v7          # pin to SHAs; persist-credentials: false
      - id: v
        env: { REF: "${{ github.ref_name }}" }    # untrusted input → env, never inline in run:
        run: echo "tag=$REF" >> "$GITHUB_OUTPUT"
```
```bash
act -l | act push | act pull_request -e event.json | act -j test      actionlint      zizmor .github
gh run list | gh run watch | gh run view --log-failed | gh workflow run deploy.yml -f environment=staging
```

## 🏅 CI/CD expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain CI, continuous delivery, continuous deployment, artifacts and "build once, deploy many"
- [ ] Write workflows with filtered triggers, inputs, job graphs, outputs, conditions and matrices
- [ ] Build a quality gate: linters, unit and integration tests with services, caches, artifacts, one required check
- [ ] Publish images with a sane tag strategy, multi-arch, scan gates, signatures, SBOM and provenance
- [ ] Deploy by digest, and verify signatures/attestations before deploying
- [ ] Secure pipelines: least-privilege tokens, environments with approvals, OIDC, no script injection, pinned actions
- [ ] Package and share pipelines with composite actions and reusable workflows
- [ ] Test real deployments on kind in CI and explain rolling, blue/green and canary
- [ ] Run GitOps with Argo CD: deploy by commit, roll back by revert, self-heal drift
- [ ] Translate a pipeline between GitHub Actions, GitLab CI and Jenkins

👉 Start: [Module 01 — CI/CD Concepts & Your First Workflow](01-cicd-concepts-and-first-workflow/README.md)
