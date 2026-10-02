# Docker Module 02 — Images & Registries 🟢

## 🎯 Objectives
- Pull, list, inspect and remove images
- Understand **layers** and why images share them
- Use tags properly (and why `latest` is dangerous in production)
- Run your **own private registry** and push/pull images to it
- Log in to real registries (Docker Hub, GitHub Container Registry)
- Clean up disk space

## 🧠 Why DevOps engineers care
Every deployment pipeline ends with "push image to registry", and every Kubernetes node starts by
"pull image from registry". Knowing how tags, layers and registries work explains slow pulls, huge
images, "it deployed the wrong version" incidents and full disks on build servers.

---

## 📖 Lesson 2.1 — Working with images

```bash
docker pull nginx:1.27-alpine           # download (doesn't run)
docker images                           # list local images (also: docker image ls)
docker image inspect nginx:1.27-alpine  # metadata: env, cmd, exposed ports, layers...
docker image inspect -f '{{.Config.Cmd}} {{.Config.ExposedPorts}}' nginx:1.27-alpine
docker history nginx:1.27-alpine        # the layers and the commands that made them
docker rmi nginx:1.27-alpine            # remove an image (fails if a container uses it)
```

## 📖 Lesson 2.2 — Layers (why images are fast to share)

An image is a **stack of read-only layers**. Each Dockerfile instruction that changes files makes
a layer. A container adds one thin **writable layer** on top:

```
 ┌─────────────────────────────┐  ← container's writable layer (lost on docker rm)
 ├─────────────────────────────┤
 │ COPY app.py                 │  layer 3   (your code — changes often)
 │ RUN apt-get install python3 │  layer 2
 │ FROM ubuntu:24.04           │  layer 1   (shared by every image built on ubuntu:24.04!)
 └─────────────────────────────┘
```

- Layers are identified by a hash (**digest**) of their content
- If two images share a base layer, it's downloaded and stored **once**
- `docker pull` only downloads layers you don't already have ("Already exists")

## 📖 Lesson 2.3 — Tags and digests

```bash
docker tag nginx:1.27-alpine my-nginx:v1       # a NEW NAME for the SAME image (no copy)
docker images | grep -E 'nginx|my-nginx'        # same IMAGE ID
docker image inspect -f '{{index .RepoDigests 0}}' nginx:1.27-alpine
# nginx@sha256:4ff1...   ← the digest: an exact, unchangeable reference
```

| Reference | Can it change? | Use for |
|-----------|----------------|---------|
| `nginx:latest` | yes, anytime | quick experiments only |
| `nginx:1.27` | yes (gets patch updates) | development |
| `nginx:1.27.2-alpine` | rarely | most deployments |
| `nginx@sha256:4ff1...` | **never** | maximum reproducibility / security |

**Tagging strategy for your own apps** (what real teams do):
```
myapp:1.4.2            ← semantic version (release)
myapp:git-3f9c2ab      ← exact commit, for traceability
myapp:main             ← moving tag for the latest build of a branch
```

## 📖 Lesson 2.4 — Run your own registry

A registry is just a container:

```bash
docker run -d --name registry -p 5000:5000 -v registry-data:/var/lib/registry registry:2

docker tag alpine:3.20 localhost:5000/tools/alpine:3.20      # name = registry/path:tag
docker push localhost:5000/tools/alpine:3.20                  # upload
curl -s localhost:5000/v2/_catalog                            # {"repositories":["tools/alpine"]}
curl -s localhost:5000/v2/tools/alpine/tags/list

docker rmi localhost:5000/tools/alpine:3.20
docker pull localhost:5000/tools/alpine:3.20                  # download it back
```

> `localhost:5000` is trusted without HTTPS. Any other registry address must use HTTPS — that's
> what you get with real registries.

## 📖 Lesson 2.5 — Real registries

| Registry | Address | Notes |
|----------|---------|-------|
| Docker Hub | `docker.io` (default) | free public images; **pull rate limits** for anonymous users |
| GitHub Container Registry | `ghcr.io` | free for public images; login with a GitHub token |
| AWS ECR | `<account>.dkr.ecr.<region>.amazonaws.com` | used with EKS/ECS |
| Google Artifact Registry | `<region>-docker.pkg.dev` | used with GKE |

```bash
docker login                                       # Docker Hub (asks for username + access token)
echo "$GITHUB_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USER --password-stdin
docker tag myapp:1.0 ghcr.io/your-user/myapp:1.0
docker push ghcr.io/your-user/myapp:1.0
docker logout ghcr.io
```

> 🔐 Use **access tokens**, never your account password, and `--password-stdin` so the token
> doesn't end up in your shell history.

## 📖 Lesson 2.6 — Saving images without a registry

```bash
docker save -o alpine.tar alpine:3.20     # image → tar file (e.g. for an offline server)
docker load -i alpine.tar                 # tar file → image
```

## 📖 Lesson 2.7 — Disk cleanup

```bash
docker system df                     # what uses space
docker image prune                   # remove "dangling" images (untagged leftovers from builds)
docker image prune -a                # remove ALL images not used by a container (careful!)
docker builder prune                 # build cache
```

---

## ⚠️ Common mistakes
- Deploying `:latest` → you can't tell which version runs, and rollbacks are guesswork
- Thinking `docker tag` copies an image (it only adds a name)
- Pushing without the registry in the name → it tries Docker Hub
- Committing registry passwords; using your real password instead of a token
- Never cleaning up → build servers run out of disk

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Image detective
For `nginx:1.27-alpine` and `python:3.12-slim`, print: size, default command (`Cmd`), exposed ports,
environment variables and number of layers (`docker image inspect -f '{{len .RootFS.Layers}}'`).

### Lab 2 ⭐⭐ — Private registry
Start a registry on port 5000 with a named volume. Push `alpine:3.20` to it as
`localhost:5000/lab/alpine:3.20` **and** `localhost:5000/lab/alpine:stable`. List the catalog and
tags with `curl`. Delete the local copies, pull from your registry, and prove it works with
`docker run --rm localhost:5000/lab/alpine:stable echo pulled-from-my-registry`.

### Lab 3 ⭐⭐ — Registry report script
`registry_report.sh [registry_url]` prints every repository and its tags from a registry's API
(`/v2/_catalog` and `/v2/<repo>/tags/list`), using `curl` + `jq`.

### Lab 4 ⭐⭐⭐ — Offline transfer
Simulate an air-gapped server: `docker save` two images into one tar, gzip it, delete the images,
`docker load` them back, and verify the image IDs are identical before and after.

---

## ✅ Checkpoint
- [ ] I can explain layers and why base images are shared
- [ ] I know why `latest` is risky and what a digest is
- [ ] I can tag and push to a registry, and run my own registry
- [ ] I know how to clean up disk space safely

👉 Next: [Module 03 — Writing Dockerfiles](../03-dockerfile/README.md)
