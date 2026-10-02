# Docker Module 03 — Writing Dockerfiles 🟡

## 🎯 Objectives
- Write a `Dockerfile` with the core instructions
- Build, tag and run your own image
- Understand the **build cache** and order instructions for fast builds
- Use `.dockerignore`, `ARG` vs `ENV`, and `CMD` vs `ENTRYPOINT`
- Containerise a real Python service (the course's [`demo-app`](../app/README.md))

## 🧠 Why DevOps engineers care
The Dockerfile is where "how do we run this app?" becomes code. A good one builds in seconds and
produces a small, secure image; a bad one rebuilds everything on every commit and ships secrets.
Writing Dockerfiles is a core DevOps task — and a common interview exercise.

---

## 📖 Lesson 3.1 — Your first Dockerfile

`Dockerfile`:
```dockerfile
FROM alpine:3.20
RUN apk add --no-cache curl
CMD ["curl", "--version"]
```

```bash
docker build -t mycurl:1.0 .        # -t = name:tag   . = the "build context" (current folder)
docker run --rm mycurl:1.0
```

## 📖 Lesson 3.2 — The instructions you'll use 95% of the time

| Instruction | What it does | Example |
|-------------|--------------|---------|
| `FROM` | base image (every Dockerfile starts here) | `FROM python:3.12-slim` |
| `WORKDIR` | set (and create) the working directory | `WORKDIR /app` |
| `COPY` | copy files from the build context into the image | `COPY app.py .` |
| `RUN` | run a command **at build time** (makes a layer) | `RUN apt-get update && apt-get install -y curl` |
| `ENV` | environment variable (build time **and** run time) | `ENV PORT=8000` |
| `ARG` | variable for **build time only** | `ARG VERSION=dev` |
| `EXPOSE` | document which port the app uses (doesn't publish it!) | `EXPOSE 8000` |
| `USER` | run as this user (security!) | `USER app` |
| `CMD` | default command when the container starts | `CMD ["python3", "app.py"]` |
| `ENTRYPOINT` | the fixed executable; `CMD` becomes its default arguments | `ENTRYPOINT ["curl"]` |
| `LABEL` | metadata | `LABEL org.opencontainers.image.source=...` |
| `HEALTHCHECK` | how Docker checks the app is healthy | Module 06 |

## 📖 Lesson 3.3 — Containerise demo-app (step by step)

Copy the app into your work folder:
```bash
mkdir -p ~/Practice/devops-bootcamp/my-work/docker/demo && cd $_
cp ../../../4-docker/app/app.py .
```

`Dockerfile`:
```dockerfile
# 1. Start from an official, slim Python image (pin the version!)
FROM python:3.12-slim

# 2. Work in /app inside the image
WORKDIR /app

# 3. Copy the code
COPY app.py .

# 4. Default configuration (can be overridden with docker run -e)
ENV PORT=8000 \
    APP_VERSION=1.0.0

# 5. Document the port
EXPOSE 8000

# 6. Start the app (exec form — see Lesson 3.6)
CMD ["python3", "app.py"]
```

```bash
docker build -t demo-app:1.0 .
docker run -d --name demo -p 8000:8000 demo-app:1.0
curl localhost:8000/            # {"message": "Hello from demo-app", "version": "1.0.0", "hostname": "<container id>"}
curl localhost:8000/health
docker logs demo
docker run --rm -e APP_MESSAGE="Hi team" -p 8001:8000 demo-app:1.0 &    # override config at run time
```

## 📖 Lesson 3.4 — The build cache (fast builds)

Docker reuses a layer if **the instruction and its inputs haven't changed**. Once one layer changes,
**every layer after it is rebuilt**. So: put things that change **rarely** first, and things that
change **often** (your code) last.

❌ Slow — any code change reinstalls all dependencies:
```dockerfile
COPY . .
RUN pip install -r requirements.txt
```

✅ Fast — dependencies are cached until `requirements.txt` changes:
```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

```bash
docker build -t demo-app:1.1 .      # watch for "CACHED" in the output
docker build --no-cache -t demo-app:1.1 .   # force a full rebuild
```

## 📖 Lesson 3.5 — `.dockerignore`

The build context (`.`) is sent to the Docker engine. Exclude what the image doesn't need — it makes
builds faster and stops secrets leaking into images:

`.dockerignore`:
```
.git
.venv
__pycache__/
*.pyc
.env
*.log
tests/
Dockerfile
```

## 📖 Lesson 3.6 — `CMD` vs `ENTRYPOINT`, exec vs shell form

```dockerfile
CMD ["python3", "app.py"]        # ✅ exec form: runs python3 directly as PID 1 → gets SIGTERM
CMD python3 app.py               # ❌ shell form: runs /bin/sh -c "...", sh is PID 1 and may NOT forward SIGTERM
```

With the shell form, `docker stop` often waits the full 10 seconds and then kills the app — no
graceful shutdown. **Always use the exec form (JSON array).**

```dockerfile
ENTRYPOINT ["curl", "-s"]        # the command is fixed
CMD ["https://example.com"]      # default argument, easy to override
```
```bash
docker run --rm mycurl https://other.example.com    # replaces only CMD
docker run --rm --entrypoint sh -it mycurl          # override the entrypoint (debugging)
```

## 📖 Lesson 3.7 — `ARG` and build-time values

```dockerfile
ARG VERSION=dev                     # available during the build only
ENV APP_VERSION=${VERSION}          # copy it into the runtime environment
LABEL org.opencontainers.image.version=${VERSION}
```
```bash
docker build --build-arg VERSION=1.2.0 -t demo-app:1.2.0 .
docker run --rm demo-app:1.2.0 python3 -c "import os; print(os.environ['APP_VERSION'])"   # 1.2.0
```

> 🔐 Never pass secrets with `ARG` or `ENV` — they're visible in `docker history` and `docker inspect`.
> Use runtime env vars / secret managers (and BuildKit `--secret` for build-time secrets).

## 📖 Lesson 3.8 — Installing packages the right way

```dockerfile
# Debian/Ubuntu based
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*          # same RUN → the cache files never land in a layer

# Alpine based
RUN apk add --no-cache curl
```

---

## ⚠️ Common mistakes
- `COPY . .` before installing dependencies → slow builds
- Shell-form `CMD` → no graceful shutdown
- `apt-get update` in a separate `RUN` from `apt-get install` → stale package lists from cache
- No `.dockerignore` → `.git`, `.env` and gigabytes of junk in the build context
- `EXPOSE` thinking it publishes a port (only `-p` does)
- Secrets in `ENV`/`ARG`/`COPY`

---

## 🧪 Labs
Work in `my-work/docker/`. Solutions in [`solutions/`](solutions/) — build them with
`docker build -t <name> solutions/<folder>`.

### Lab 1 ⭐ — Tools image
Build `nettools:1.0` from `alpine:3.20` with `curl`, `bind-tools` (for `dig`) and `jq`, with
`ENTRYPOINT ["sh"]`. Use it to run `dig +short example.com` and `curl -s https://api.github.com | jq .current_user_url`.

### Lab 2 ⭐⭐ — Containerise demo-app
Write the Dockerfile from Lesson 3.3, with a `.dockerignore` and an `ARG VERSION` that ends up in
`APP_VERSION` and an OCI label. Build `demo-app:1.0.0` and `demo-app:1.1.0`; run both at once on
ports 8000 and 8001 and show each reports its own version.

### Lab 3 ⭐⭐ — Cache experiment
Add a fake `requirements.txt` step (`RUN pip install --no-cache-dir -r requirements.txt` with
`requests==2.32.3`). Measure build time with `time docker build ...`: (a) first build, (b) rebuild with
no changes, (c) after editing `app.py`, (d) after editing `requirements.txt`. Then swap the order of
`COPY` lines and measure (c) again. Write down what you see.

### Lab 4 ⭐⭐⭐ — Graceful shutdown proof
Build two images of demo-app: one with exec-form `CMD`, one with shell-form. For each, time
`docker stop`. Explain the difference using what you learned about signals in Shell Module 09.

---

## ✅ Checkpoint
- [ ] I can write a Dockerfile with `FROM WORKDIR COPY RUN ENV EXPOSE CMD`
- [ ] I order instructions so dependency layers stay cached
- [ ] I always use a `.dockerignore` and exec-form `CMD`
- [ ] I know `ARG` vs `ENV`, and never put secrets in either

👉 Next: [Module 04 — Volumes & Networking](../04-volumes-and-networking/README.md)
