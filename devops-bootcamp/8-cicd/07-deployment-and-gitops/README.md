# CI/CD Module 07 — Deployment Pipelines & GitOps 🔴

## 🎯 Objectives
- Run **end-to-end tests** in CI on a throwaway Kubernetes cluster (kind)
- Compare deployment strategies: **rolling**, **blue/green**, **canary**, feature flags
- Do a blue/green switch and an instant rollback yourself
- Deploy with **GitOps**: CI commits the new image tag, **Argo CD** syncs the cluster to Git
- Automate **releases**: tags, generated release notes

## 🧠 Why DevOps engineers care
"Push button, deploy" isn't enough — a good delivery process tests the real deployment before production, limits
the blast radius of a bad release, and makes rollback boring. GitOps has become the standard way to deploy to
Kubernetes: Git is the single source of truth, every change is a reviewed commit, and the cluster heals itself back
to what Git says.

---

## 📖 Lesson 7.1 — Push vs pull deployments

```
 PUSH (CI deploys)                              PULL (GitOps)
 CI ──kubectl apply──► cluster                  CI ──commit new tag──► Git ◄──watches── Argo CD ──► cluster
 CI needs cluster credentials                   only Argo CD (inside the cluster) has cluster access
 drift goes unnoticed                           drift is detected and undone
 rollback = re-run an old pipeline              rollback = git revert
```
Push is fine for small setups and for **test** clusters (Lesson 7.2). For production Kubernetes, prefer pull.

## 📖 Lesson 7.2 — End-to-end tests on kind, inside CI

```yaml
      - uses: helm/kind-action@v1                  # a real Kubernetes cluster in the CI VM (~1 min)
        with:
          cluster_name: e2e
      - run: |
          docker build -t demo-app:e2e .
          kind load docker-image demo-app:e2e --name e2e        # no registry needed
      - run: |
          cd deploy/k8s && kustomize edit set image demo-app=demo-app:e2e
          kubectl apply -k . && kubectl rollout status deployment/demo-app --timeout=120s
      - run: |
          kubectl port-forward service/demo-app 8080:80 &
          scripts/smoke_test.sh http://127.0.0.1:8080 "e2e-${GITHUB_SHA::7}"
```
This tests the **real manifests** — probes, security context, Service selector — on every pull request.
On failure, print `kubectl describe` and `kubectl logs` so the PR author can see why.

## 📖 Lesson 7.3 — Deployment strategies

| Strategy | How | Rollback | Cost |
|----------|-----|----------|------|
| **Rolling** | replace pods a few at a time (Phase 5) | `kubectl rollout undo` (minutes) | none |
| **Blue/green** | run old (blue) and new (green) side by side, switch the Service | flip back (seconds) | 2× capacity during the switch |
| **Canary** | send 5% → 25% → 100% of traffic to the new version, watching metrics | stop and shift back | needs traffic splitting (Argo Rollouts, Gateway API, a service mesh) |
| **Feature flags** | ship code dark, turn features on per user | flip the flag | flag management |

Blue/green by hand ([`solutions/blue-green/`](solutions/blue-green/)):
```bash
kubectl apply -f blue.yaml -f green.yaml -f service.yaml   # Service selects color: blue
./switch_color.sh green          # only switches if green is fully ready
./switch_color.sh blue           # instant rollback
```

## 📖 Lesson 7.4 — GitOps with Argo CD

```bash
./solutions/argocd/install_argocd.sh          # into your kind lab cluster, pinned version
kubectl apply -f solutions/argocd/application.yaml
```
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  source:
    repoURL: https://github.com/YOUR-USER/cicd-lab.git
    targetRevision: main
    path: deploy/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: demo
  syncPolicy:
    automated:
      prune: true                # remove what was deleted from Git
      selfHeal: true             # undo manual changes
```
Now `kubectl scale deployment/demo-app --replicas=5 -n demo` — Argo CD puts it back to 2 within minutes. That's
**drift correction**. Open the UI to see the resource tree, sync status and history.

CI's job becomes: build, push, then **commit the new tag** ([`gitops-bump.yml`](solutions/workflows/gitops-bump.yml)):
```yaml
      - run: scripts/bump_image.sh deploy/k8s/kustomization.yaml "$IMAGE" "$TAG"
      - run: |
          git commit -am "deploy: demo-app $TAG"
          git push
```
If `main` is protected (Module 01, Lab 4), let the bump job open a pull request instead (`gh pr create`) — then
deploying to production *is* merging a PR. Many teams keep manifests in a separate "config" repo for exactly this.

## 📖 Lesson 7.5 — Releases

```yaml
on:
  push:
    tags: ["v*.*.*"]
...
      - env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: gh release create "$GITHUB_REF_NAME" --verify-tag --generate-notes
```
Use **semantic versioning**: `MAJOR.MINOR.PATCH` — breaking change, new feature, bug fix. Conventional commit
messages (`feat:`, `fix:`) let tools generate changelogs and pick the next version automatically.

---

## ⚠️ Common mistakes
- Only testing code in CI, never the deployment manifests → broken probes found in production
- Blue/green switch before the new version is fully ready
- GitOps plus manual `kubectl` edits → Argo CD reverts them (by design!)
- CI bump commits that trigger the pipeline again → an endless loop (`paths-ignore: deploy/**`)
- Rolling back by building old code again instead of redeploying the old, already-tested image

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Labs 2–3 use your kind lab cluster from Phase 5.

### Lab 1 ⭐⭐ — e2e on kind
Add `e2e-kind.yml`: create a kind cluster, build and load the image, apply the real manifests with the test image,
wait for the rollout, smoke test through the Service, print debug info on failure. Break the readiness probe path
in a PR and watch the e2e job catch it.

### Lab 2 ⭐⭐ — Blue/green by hand
Build `demo-app:1.0.0` and `1.1.0`, load them into kind, apply `blue.yaml`, `green.yaml`, `service.yaml`. Run a
`while true; do curl …; sleep 0.2; done` loop through a port-forward while you `switch_color.sh green` and back.
Count failed requests (it should be zero).

### Lab 3 ⭐⭐⭐ — GitOps
Install Argo CD, apply the Application for your lab repo, add `gitops-bump.yml`. Merge a change to `app.py`:
CI builds `sha-…`, commits the bump, Argo CD deploys it. Then `git revert` the bump commit and watch the old
version come back. Finally make a manual `kubectl` change and watch self-heal undo it.

### Lab 4 ⭐⭐ — Releases
Add `release.yml`. Merge two PRs with clear titles, then push `v1.0.0`. Check the generated release notes and that
the image workflow from Module 04 published `1.0.0`.

---

## ✅ Checkpoint
- [ ] I test the real deployment (manifests + image) on a throwaway cluster in CI
- [ ] I can explain rolling, blue/green and canary, and did a zero-downtime blue/green switch
- [ ] I can set up Argo CD, deploy by commit, and roll back with `git revert`
- [ ] Every release has a version tag, a release page and generated notes

👉 Next: [Module 08 — CI/CD Capstone](../08-capstone/README.md)
