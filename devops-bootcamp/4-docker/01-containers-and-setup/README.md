# Docker Module 01 — Containers & Your First `docker run` 🟢

## 🎯 Objectives
- Explain what a container is, and how it differs from a virtual machine
- Know the key words: **image**, **container**, **registry**, **Docker Engine**
- Run, list, stop, start, remove and inspect containers
- Read container logs and get a shell inside a running container
- Clean up after yourself

## 🧠 Why DevOps engineers care
"It works on my machine" used to end careers. A container packages an app **with everything it
needs** (runtime, libraries, config) so it runs the same on your laptop, in CI and in production.
Kubernetes, most CI systems and every modern cloud platform run containers. This is the foundation
for the next three phases.

> **Before you start:** finish [Part 2 of the Ubuntu setup](../../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md)
> and check that `docker run --rm hello-world` works **without** `sudo`.

---

## 📖 Lesson 1.1 — Containers vs virtual machines

```
   VIRTUAL MACHINES                          CONTAINERS
 ┌───────┐ ┌───────┐ ┌───────┐         ┌───────┐ ┌───────┐ ┌───────┐
 │ App A │ │ App B │ │ App C │         │ App A │ │ App B │ │ App C │
 │ libs  │ │ libs  │ │ libs  │         │ libs  │ │ libs  │ │ libs  │
 │GuestOS│ │GuestOS│ │GuestOS│         └───────┘ └───────┘ └───────┘
 └───────┘ └───────┘ └───────┘         ┌───────────────────────────┐
 ┌───────────────────────────┐         │   Docker Engine           │
 │   Hypervisor              │         ├───────────────────────────┤
 ├───────────────────────────┤         │   ONE Linux kernel (host) │
 │   Host OS / hardware      │         └───────────────────────────┘
 └───────────────────────────┘
```

| | Virtual machine | Container |
|--|-----------------|-----------|
| Contains | a whole operating system | just the app + its libraries |
| Size | gigabytes | megabytes |
| Starts in | minutes | **milliseconds to seconds** |
| Isolation | very strong (separate kernel) | strong (shared kernel, isolated with Linux namespaces + cgroups) |

A container is really just a **normal Linux process** that has been isolated: it sees its own
filesystem, network and process list, and has limits on CPU/memory.

## 📖 Lesson 1.2 — The four key words

| Word | Meaning | Analogy |
|------|---------|---------|
| **Image** | a read-only template: files + metadata (which command to run) | a class / a recipe |
| **Container** | a running (or stopped) instance of an image | an object / a cooked meal |
| **Registry** | a server that stores images (Docker Hub, GHCR, AWS ECR) | an app store |
| **Docker Engine** | the background service (`dockerd`) that builds and runs containers | the kitchen |

Image names look like `registry/namespace/name:tag`:
```
nginx:1.27            → docker.io/library/nginx:1.27   (Docker Hub "official image")
ghcr.io/acme/api:2.3  → GitHub Container Registry, namespace acme, image api, tag 2.3
```
No tag = `:latest` (which just means "whatever was pushed last" — not necessarily the newest!).

## 📖 Lesson 1.3 — Your first containers

```bash
docker run --rm hello-world                 # download the image, run it, remove the container
docker run --rm alpine:3.20 echo "hi from a container"
docker run --rm alpine:3.20 cat /etc/os-release   # a different "OS" than your Ubuntu!
docker run --rm -it alpine:3.20 sh          # -i interactive, -t terminal → a shell inside
#   / # ls ; ps ; hostname ; exit
```

What `docker run` did:
1. Looked for the image locally → not found → **pulled** it from Docker Hub
2. **Created** a container from it
3. **Started** it, running its command
4. `--rm` → **deleted** the container when the command finished

## 📖 Lesson 1.4 — Long-running containers

```bash
docker run -d --name web -p 8080:80 nginx:1.27-alpine
#          │   │          │
#          │   │          └ publish: host port 8080 → container port 80
#          │   └ give it a name (otherwise Docker invents one like "angry_turing")
#          └ detached: run in the background

curl localhost:8080                 # nginx answers from inside the container!
docker ps                           # running containers
docker ps -a                        # ALL containers, including stopped ones
```

## 📖 Lesson 1.5 — The container lifecycle

```
 docker create ──► Created ──docker start──► Running ──docker stop──► Exited
                                  ▲   │                                  │
                                  │   └──docker pause/unpause            │
                                  └──────────────── docker start ◄───────┘
                     docker rm  (remove; -f forces removal of a running one)
```

```bash
docker stop web          # graceful: sends SIGTERM, waits 10s, then SIGKILL
docker start web
docker restart web
docker rm -f web         # stop + remove
```

## 📖 Lesson 1.6 — Logs, exec, inspect, stats

```bash
docker run -d --name web -p 8080:80 nginx:1.27-alpine
curl -s localhost:8080 > /dev/null

docker logs web                 # everything the container printed (stdout/stderr)
docker logs -f --tail 20 web    # follow live, like tail -f
docker exec web ls /usr/share/nginx/html     # run a command inside a RUNNING container
docker exec -it web sh          # open a shell inside it (exit leaves; the container keeps running)
docker inspect web              # ALL details as JSON
docker inspect -f '{{.NetworkSettings.IPAddress}}' web   # one field (Go template)
docker stats --no-stream        # CPU / memory usage
docker top web                  # processes inside the container
```

> 🧠 Containers should log to **stdout/stderr**, not to files. Then `docker logs`, Kubernetes and
> every log platform can collect them.

## 📖 Lesson 1.7 — Environment variables & resource limits

```bash
docker run --rm -e APP_ENV=prod -e LOG_LEVEL=debug alpine:3.20 env | grep -E 'APP_ENV|LOG_LEVEL'
docker run -d --name limited --memory 128m --cpus 0.5 nginx:1.27-alpine
docker stats --no-stream limited
docker rm -f limited
```

## 📖 Lesson 1.8 — Cleaning up

```bash
docker ps -aq                         # IDs of all containers
docker rm -f $(docker ps -aq)         # remove ALL containers (careful!)
docker container prune                # remove stopped containers
docker system df                      # disk used by images/containers/volumes
docker system prune                   # remove stopped containers, unused networks, dangling images
```

---

## ⚠️ Common mistakes
- Forgetting `-d` → the terminal is "stuck" (it's showing the container's output; `Ctrl+C` stops it)
- `-p 80:8080` vs `-p 8080:80` → it's always **host:container**
- "port is already allocated" → something else uses that host port; pick another
- Editing files inside a container with `exec` and expecting them to survive `docker rm` — they don't
- Using `:latest` and being surprised when it changes

---

## 🧪 Labs
Work in `~/Practice/devops-bootcamp/my-work/docker/`. Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Explore
1. Run `alpine:3.20`, `ubuntu:24.04` and `python:3.12-slim` with `cat /etc/os-release`. What differs?
2. Run `python:3.12-slim python3 -c "print(2**10)"` — Python without installing Python!
3. `docker images` — how big is each image?

### Lab 2 ⭐ — A web server
Run nginx detached as `web` on host port 8080, check it with `curl`, view its logs, open a shell in
it, change `/usr/share/nginx/html/index.html` to say "Hello DevOps", see the change with `curl`,
then remove the container and start a new one — is your change still there? Why not?

### Lab 3 ⭐⭐ — Lifecycle drill
Write `lifecycle.sh` that: starts nginx as `drill`, waits until `curl` succeeds (retry loop!), prints
its IP with `docker inspect -f`, stops it and prints its status (`docker inspect -f '{{.State.Status}}'`),
starts it again, then removes it. Use `set -euo pipefail` and a `trap` that always removes the container.

### Lab 4 ⭐⭐ — Three web servers
Start three nginx containers `web1..web3` on ports 8081–8083 in a loop. Show them with
`docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}'`. Stop the middle one and
show the difference between `docker ps` and `docker ps -a`. Clean up all three with one command.

---

## ✅ Checkpoint
- [ ] I can explain image vs container vs registry
- [ ] I know `run -d --name -p -e --rm -it`, `ps -a`, `logs -f`, `exec -it`, `stop`, `rm -f`
- [ ] I know `-p` is always host:container
- [ ] I know why files changed inside a container disappear when it's removed

👉 Next: [Module 02 — Images & Registries](../02-images-and-registries/README.md)
