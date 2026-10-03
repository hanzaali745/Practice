# CI/CD Module 08 — CI/CD Capstone 🏆

> **CEO note:** This is the pipeline I'd expect a DevOps engineer to set up in their first month on my team: every
> change tested before review, one signed image built once, deployed to staging automatically and promoted to
> production with an approval — all from Git, all auditable, rollback in one commit.

**Definition of Done:**
- [ ] Pull requests run lint, unit, integration and end-to-end (kind) tests; one required gate check
- [ ] Every push to `main` builds **one** image: scanned, pushed, signed, with SBOM and provenance
- [ ] Staging is updated automatically through Git (GitOps); production gets the **same digest** after approval
- [ ] Least-privilege permissions, actions pinned to SHAs, Dependabot with cooldown, no stored cloud keys
- [ ] actionlint + zizmor clean; the pipeline itself is checked by a script
- [ ] Release tags produce release notes; rollback is `git revert` of a deploy commit
- [ ] A README with the pipeline diagram and how to roll back

---

## Project 1 ⭐⭐⭐ — The complete pipeline (full reference solution)

```
 pull request ──► ci.yml:  lint ─┬─ unit ────────┬─ e2e (kind) ── ci-ok ✅ (required to merge)
                                 └─ integration ─┘

 merge to main ─► delivery.yml:
                  ci (same checks) ─► image ─────────────► staging ──────────► production
                                      build · scan · push    commit new digest    ⏸ approval, then commit
                                      sign · SBOM · attest   to overlays/staging   the SAME digest to
                                                                                   overlays/production
                                                    Argo CD (in your cluster) ◄── watches both overlays

 tag v1.2.3 ────► release.yml: GitHub release with generated notes
```

```
pipeline/
├── .github/
│   ├── workflows/ci.yml             # PRs (and called by delivery) — nothing published
│   ├── workflows/delivery.yml       # main → image → staging → (approval) → production
│   ├── workflows/release.yml        # tags → release notes
│   ├── actions/setup-demo/          # composite action (Module 06)
│   └── dependabot.yml               # pinned actions/pip/Docker updates, 7-day cooldown
├── deploy/base/                     # Deployment + Service
├── deploy/overlays/{staging,production}/   # namespace, replicas, and the image digest CI writes
├── argocd/applications.yaml         # one Argo CD Application per environment
├── scripts/bump_image.sh            # the GitOps "deploy" — edits one kustomization file
├── other-ci/.gitlab-ci.yml          # Project 2
├── other-ci/Jenkinsfile             # Project 3
├── install_into.sh                  # copy all this into your lab repo as one commit
└── check.sh                         # the pipeline's own quality gate
```

👉 Reference: [`solutions/pipeline/`](solutions/pipeline/)

```bash
cd ~/Practice/devops-bootcamp/8-cicd/08-capstone/solutions/pipeline
./check.sh                                   # actionlint · zizmor · pins · shellcheck · manifests
./install_into.sh ~/cicd-lab                 # one commit in your lab repo
cd ~/cicd-lab
act pull_request -e act-event.json -W .github/workflows/ci.yml   # run CI locally (e2e skipped)
git push
```
Then on GitHub:
1. **Settings → Environments**: `staging` (no rules), `production` (required reviewer: you; branch: `main`).
2. **Settings → Branches**: require pull requests and the `ci-ok` check on `main`; allow **GitHub Actions** to
   bypass, so the deploy commits can be pushed (or change the deploy jobs to open PRs — Module 07).
3. In your kind cluster: `install_argocd.sh` (Module 07), then `kubectl apply -f argocd/applications.yaml`.
4. Merge a PR that changes the greeting. Watch: CI → image → staging commit → Argo CD syncs `demo-staging` →
   approve → production commit → Argo CD syncs `demo-prod`. Both run the same digest.

**Rollback:** `git revert <the deploy(production) commit>` and push — Argo CD puts the previous digest back.

**Stretch goals:** a smoke test of staging before the approval (needs staging reachable from CI — e.g. a
self-hosted runner in your lab, or a cloud cluster in Phase 11) · Argo CD Image Updater instead of bump commits ·
Kyverno policy that refuses unsigned images · a Slack notification on production deploys.

---

## Project 2 ⭐⭐ — The same pipeline in GitLab CI
Import your lab repo into a free GitLab.com project and use
[`other-ci/.gitlab-ci.yml`](solutions/pipeline/other-ci/.gitlab-ci.yml): stages, cached pip, a JUnit report in the
merge request, a Redis service, the built-in registry, and a `when: manual` production job. Write down how each
GitHub Actions concept maps to GitLab's.

## Project 3 ⭐⭐ — The same pipeline in Jenkins
Run Jenkins in Docker (`jenkins/jenkins:lts`), add the Docker Pipeline plugin, and create a Multibranch Pipeline
from your repo with [`other-ci/Jenkinsfile`](solutions/pipeline/other-ci/Jenkinsfile): parallel test stages, JUnit
publishing, credentials binding and an `input` approval step. Many enterprises still run Jenkins — knowing it opens
doors.

## Project 4 ⭐⭐⭐ — Platform pipelines
Move the reusable pieces into a separate `pipelines` repo (Module 06): a reusable `python-service-ci.yml` and a
`container-delivery.yml` with inputs for image name and overlay paths. Make a second service (e.g. your Python
capstone from Phase 1) use them with a 20-line workflow.

---

## 🎓 CI/CD phase complete!
Tick the [CI/CD expert checklist](../README.md#-cicd-expert-checklist), then continue with monitoring — because once
you deploy many times a day, you need to *see* what each deploy does.

👉 Next phase: [Phase 9 — Monitoring](../../9-monitoring/README.md)
