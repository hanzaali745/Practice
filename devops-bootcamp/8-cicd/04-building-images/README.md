# CI/CD Module 04 — Building & Publishing Images 🟡

## 🎯 Objectives
- Build images in CI with **Buildx** and push them to **GitHub Container Registry (GHCR)**
- Generate a sensible **tag strategy** automatically (sha, branch, semver)
- Speed up builds with the GitHub Actions **layer cache**
- Build **multi-architecture** images (amd64 + arm64)
- **Scan** images and fail the pipeline on fixable HIGH/CRITICAL vulnerabilities
- **Sign** images and publish **SBOM** and **provenance** — and verify them before deploying

## 🧠 Why DevOps engineers care
The image is the artifact you deploy everywhere, so CI must build it once, label it clearly, prove it's safe and
prove where it came from. Supply-chain attacks (a tampered image, a poisoned dependency) are one of the biggest
risks in modern delivery; signing, SBOMs and provenance are how teams defend against them — and auditors ask for them.

---

## 📖 Lesson 4.1 — Registries and GHCR

Your image lives at `ghcr.io/<owner>/<repo>`. Inside Actions, the built-in `GITHUB_TOKEN` can push to it if the job
has `packages: write`:
```yaml
permissions:
  contents: read
  packages: write
...
      - uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
```
After the first push, open your GitHub profile → **Packages** → link the package to the repository and set its
visibility. Other registries (Docker Hub, AWS ECR — Phase 11, GitLab) work the same way with their own login action.

## 📖 Lesson 4.2 — Tags: who, what, when

```yaml
      - id: meta
        uses: docker/metadata-action@v6
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha,format=short           # sha-1a2b3c4   — every build, immutable-ish
            type=ref,event=branch           # main          — moves with the branch
            type=ref,event=pr               # pr-42
            type=semver,pattern={{version}}             # 1.2.3 on tag v1.2.3
            type=semver,pattern={{major}}.{{minor}}     # 1.2
```
| Event | Tags pushed |
|-------|-------------|
| PR #42 | nothing pushed (build + scan only) |
| push to `main` | `sha-1a2b3c4`, `main` |
| tag `v1.2.3` | `sha-…`, `1.2.3`, `1.2`, `latest` |

Tags can be moved; a **digest** (`@sha256:…`) can't. Deploy by digest in production.

## 📖 Lesson 4.3 — Buildx, cache and multi-arch

```yaml
      - uses: docker/setup-qemu-action@v4
      - uses: docker/setup-buildx-action@v4
      - id: build
        uses: docker/build-push-action@v7
        with:
          context: .
          platforms: linux/amd64,linux/arm64     # Graviton servers, Raspberry Pis, Apple silicon laptops
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max            # unchanged layers are reused across runs
          provenance: mode=max
          sbom: true
```
`steps.build.outputs.digest` is the digest of what was pushed — pass it on to signing and deployment.

## 📖 Lesson 4.4 — Scan before you ship

```yaml
      - uses: docker/build-push-action@v7
        with: { context: ., load: true, tags: "demo-app:scan" }
      - run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.75.0 \
            image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 demo-app:scan
```
`--ignore-unfixed` = only fail on problems you **can** fix. When the scan fails (it will!), you have three honest
options:
1. **Patch in the image** — the lab Dockerfile runs `apt-get upgrade` so OS fixes newer than the base image are applied.
2. **Rebuild on a fresher base** — `docker build --pull`, or bump the base tag; schedule a weekly rebuild
   (`on: schedule`) so images don't rot.
3. **Accept the risk, with an expiry** — `.trivyignore`:
   ```
   # CVE-2026-12345: not reachable — we never parse untrusted regexes. Owner: you. Review by:
   CVE-2026-12345 exp:2026-12-31
   ```
   Never ignore without a reason, an owner and an expiry date.

## 📖 Lesson 4.5 — Sign, SBOM, provenance

```yaml
    permissions:
      id-token: write                            # lets the job get an OIDC identity from GitHub
      attestations: write
...
      - uses: actions/attest-build-provenance@v4
        with:
          subject-name: ghcr.io/${{ github.repository }}
          subject-digest: ${{ steps.build.outputs.digest }}
          push-to-registry: true
      - uses: sigstore/cosign-installer@v4
      - run: cosign sign --yes "ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}"
```
**Keyless signing**: no private key to leak — the signature proves *"built by workflow X in repo Y"*.
**SBOM**: the list of every package in the image (answer "are we affected by CVE-…?" in seconds).
**Provenance**: which commit, workflow and runner built it.

Verify before deploying ([`solutions/verify_image.sh`](solutions/verify_image.sh)):
```bash
cosign verify ghcr.io/you/cicd-lab@sha256:... \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/you/cicd-lab/.github/workflows/'
gh attestation verify oci://ghcr.io/you/cicd-lab@sha256:... --repo you/cicd-lab
```
In Kubernetes, admission controllers (Kyverno, Sigstore policy-controller) can refuse unsigned images automatically.

---

## ⚠️ Common mistakes
- Pushing from pull requests (a PR from a fork must never be able to publish your image)
- Only a `latest` tag → you can't tell what's running or roll back
- Deploying a tag instead of a digest in production
- Ignoring scan findings forever, or never rebuilding images whose base got security fixes
- Uppercase letters in the image name (registries require lowercase)

---

## 🧪 Labs
Solution: [`solutions/workflows/image.yml`](solutions/workflows/image.yml) and
[`solutions/verify_image.sh`](solutions/verify_image.sh).

### Lab 1 ⭐ — First push to GHCR
Add a job that logs in, builds and pushes `ghcr.io/<you>/cicd-lab:main` on pushes to `main`. Pull it on your laptop
and run it. Link the package to the repo.

### Lab 2 ⭐⭐ — Tag strategy
Use `docker/metadata-action` for sha, branch, PR and semver tags; PRs build but don't push. Push a `v0.2.0` tag and
check that `0.2.0`, `0.2` and `latest` appear. `docker buildx imagetools inspect` the result.

### Lab 3 ⭐⭐ — Scan gate
Add the Trivy step. Make it fail (use an old base image like `python:3.12.0-slim`), then fix it properly with option
1 or 2 from Lesson 4.4. Add one `.trivyignore` entry with a reason and expiry and explain it in the PR.

### Lab 4 ⭐⭐⭐ — Multi-arch, signed and attested
Build amd64 + arm64 with cache, push with SBOM + provenance, attest and sign. Run `verify_image.sh` against your
image. Then try to verify with a wrong `--certificate-identity-regexp` and watch it fail — that's the protection.

---

## ✅ Checkpoint
- [ ] I can push images to GHCR with a clear tag strategy, and PRs never push
- [ ] I use the layer cache and can build multi-arch images
- [ ] My pipeline fails on fixable HIGH/CRITICAL vulnerabilities, and I handle findings honestly
- [ ] I can sign images keylessly and verify signatures and attestations before deploying

👉 Next: [Module 05 — Secrets, Environments & Pipeline Security](../05-secrets-and-security/README.md)
