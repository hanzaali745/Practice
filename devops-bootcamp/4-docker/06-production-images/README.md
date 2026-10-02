# Docker Module 06 — Production-ready Images 🔴

## 🎯 Objectives
- Shrink images with **multi-stage builds** and minimal bases (`slim`, `alpine`, `distroless`, `scratch`)
- Run as a **non-root user** and add a `HEALTHCHECK`
- Harden containers at runtime: read-only filesystem, dropped capabilities, no privilege escalation
- Handle signals properly (PID 1, `--init`)
- **Scan** images for vulnerabilities
- Build and push images automatically in **CI** with good tags

## 🧠 Why DevOps engineers care
Every extra package in an image is something to download, store, patch and attack. Security teams
will scan your images and reject ones running as root with hundreds of CVEs. Small, hardened,
automatically built images deploy faster, cost less and pass audits.

---

## 📖 Lesson 6.1 — Pick a small base image

| Base | Size | Has a shell? | Use when |
|------|------|--------------|----------|
| `ubuntu:24.04` | ~80 MB | yes | you need lots of tools (rarely for apps) |
| `python:3.12` | ~1 GB | yes | **building** (has compilers) |
| `python:3.12-slim` | ~130 MB | yes | most Python apps ✅ |
| `alpine:3.20` | ~8 MB | yes (`sh`) | tiny images; uses musl libc (some Python wheels need compiling) |
| `gcr.io/distroless/...` | 2–50 MB | **no** | production: only your app + its runtime |
| `scratch` | 0 MB | no | fully static binaries (Go, Rust) |

No shell = attackers can't get a shell either — but you can't `docker exec -it ... sh` to debug.
(Use `docker debug` or a debug sidecar instead.)

## 📖 Lesson 6.2 — Multi-stage builds

Build in a big image with compilers, then **copy only the result** into a small one:

```dockerfile
# ---- stage 1: build ----
FROM golang:1.23 AS build
WORKDIR /src
COPY main.go .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/server main.go

# ---- stage 2: run ----
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/server /server
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]
```
Result: a builder image of **hundreds of MB** → a final image of about **2 MB**. Compilers, source and caches never ship.

For Python, the same idea builds wheels/venv in one stage and copies the venv:
```dockerfile
FROM python:3.12-slim AS build
RUN python -m venv /venv
COPY requirements.txt .
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim
COPY --from=build /venv /venv
ENV PATH="/venv/bin:$PATH"
COPY app.py /app/
...
```

## 📖 Lesson 6.3 — Never run as root

By default containers run as **root**. If the app is compromised, the attacker is root inside the
container (and container escapes become much more dangerous).

```dockerfile
RUN groupadd --system --gid 10001 app \
 && useradd  --system --uid 10001 --gid app --no-create-home app
COPY --chown=app:app app.py /app/
USER app                       # everything after this — and the running container — is non-root
```
```bash
docker exec <container> id     # uid=10001(app) gid=10001(app)
```
Use a **numeric** UID (Kubernetes' `runAsNonRoot` check can only verify numbers).

## 📖 Lesson 6.4 — `HEALTHCHECK`

```dockerfile
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD python3 -c "import urllib.request,sys; urllib.request.urlopen('http://localhost:8000/health', timeout=2)" || exit 1
```
```bash
docker ps                      # STATUS: Up 20 seconds (healthy)
docker inspect -f '{{.State.Health.Status}}' demo
```
(Kubernetes ignores `HEALTHCHECK` and uses its own **probes** — Kubernetes Module 07 — but Docker, Compose and Swarm use it.)

## 📖 Lesson 6.5 — Runtime hardening flags

```bash
docker run -d --name demo \
  --read-only --tmpfs /tmp \              # the filesystem can't be modified (except /tmp)
  --cap-drop ALL \                        # remove all Linux capabilities (root "superpowers")
  --security-opt no-new-privileges \      # setuid binaries can't raise privileges
  --memory 128m --cpus 0.5 \              # limits: one container can't starve the host
  --pids-limit 100 \                      # stops fork bombs
  -p 127.0.0.1:8000:8000 demo-app:secure
```
If the app still works with all of these, it's in great shape for production (and Kubernetes'
`securityContext` uses exactly the same ideas).

## 📖 Lesson 6.6 — PID 1 and signals

The first process in a container is **PID 1**, which Linux treats specially: it ignores signals it
doesn't explicitly handle, and it must reap zombie processes. So:
- Use **exec-form** `CMD`/`ENTRYPOINT` (Module 03) so your app *is* PID 1
- Make your app handle `SIGTERM` (demo-app does — see `signal.signal` in `app.py`)
- If your app can't do that (or spawns children), add a tiny init: `docker run --init ...`
  or install `tini` and use `ENTRYPOINT ["tini", "--", "your-app"]`

## 📖 Lesson 6.7 — Labels and metadata

```dockerfile
LABEL org.opencontainers.image.title="demo-app" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/you/repo" \
      org.opencontainers.image.revision="${GIT_SHA}"
```
Registries (e.g. GitHub) use these to link images to code. `docker inspect` shows them.

## 📖 Lesson 6.8 — Scan images for vulnerabilities

**Trivy** (free, very common in CI) runs as a container itself:
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:0.56.2 image --severity HIGH,CRITICAL demo-app:secure
```
Or Docker's built-in `docker scout quickview demo-app:secure` (needs a Docker account).

Fix findings by: updating the base image tag, removing packages you don't need, switching to `slim`/
distroless, and **rebuilding regularly** (base images get security patches).

## 📖 Lesson 6.9 — Build & push in CI (GitHub Actions)

`.github/workflows/docker.yml` — on every push to `main` (and on tags `v*`), build and push to GitHub
Container Registry with good tags:

```yaml
name: docker
on:
  push:
    branches: [main]
    tags: ["v*"]
permissions:
  contents: read
  packages: write          # allow pushing to ghcr.io with the built-in token
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha                        # ghcr.io/you/repo:sha-3f9c2ab
            type=ref,event=branch           # :main
            type=semver,pattern={{version}} # :1.4.2 when you push tag v1.4.2
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

> 💡 `docker buildx build --platform linux/amd64,linux/arm64 ...` builds for Intel **and** ARM
> (AWS Graviton, Apple Silicon) in one go.

---

## ⚠️ Common mistakes
- Shipping compilers, `git`, test files and caches in the final image
- Running as root "because it's easier"
- `latest` base images → builds change silently; pin versions and rebuild on purpose
- A healthcheck that calls a tool the image doesn't have (`curl` in a slim image!)
- Ignoring scan results — or blocking deploys on every LOW finding (gate on HIGH/CRITICAL)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) with `verify.sh` that checks every requirement.

### Lab 1 ⭐⭐ — Harden demo-app
Write `Dockerfile.secure` for demo-app: `python:3.12-slim`, non-root numeric UID 10001, `HEALTHCHECK`,
OCI labels, `PYTHONDONTWRITEBYTECODE=1`. Verify: `id` shows uid 10001, status becomes `(healthy)`.

### Lab 2 ⭐⭐ — Multi-stage Go
Build the tiny Go server in `solutions/go-server/` with a multi-stage Dockerfile onto distroless. Compare
the size of the builder image and the final image (`docker images`).

### Lab 3 ⭐⭐ — Lock it down
Run your secure demo-app with `--read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges
--memory 128m --pids-limit 100`. Prove `/`, `/health` and `/visits` still work, and that writing to `/app`
inside the container fails.

### Lab 4 ⭐⭐⭐ — Scan and compare
Scan `python:3.12` (full), `python:3.12-slim` and your `demo-app:secure` with Trivy, counting
HIGH+CRITICAL findings for each (`--format json` + `jq`). Then add the GitHub Actions workflow above to
a repo of your own and get an image published to `ghcr.io`.

---

## ✅ Checkpoint
- [ ] I can write a multi-stage build and explain why it's smaller
- [ ] My images run as a numeric non-root user with a healthcheck
- [ ] I know the runtime hardening flags and that my app works with them
- [ ] I can scan an image and build/push it from CI with commit-SHA tags

👉 Next: [Module 07 — Docker Capstone](../07-capstone/README.md)
