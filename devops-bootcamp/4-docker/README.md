# 🐳 Phase 4: Docker

> **Before you start:** finish Phases 1–3 and do [Part 2 of the Ubuntu setup](../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md).
> Your Python, Shell and Bash skills are used everywhere here: Dockerfiles run shell commands,
> entrypoints are POSIX `sh`, deploy tooling is Bash, and the sample app is Python.

## The sample app

[`app/`](app/README.md) is **demo-app**, a tiny dependency-free Python web service used through the
Docker *and* Kubernetes phases: `/`, `/health`, and a `/visits` counter that uses Redis when available.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Containers & Your First `docker run`](01-containers-and-setup/README.md) | 🟢 | run, inspect, log into and clean up containers |
| 02 | [Images & Registries](02-images-and-registries/README.md) | 🟢 | layers, tags, digests, your own private registry |
| 03 | [Writing Dockerfiles](03-dockerfile/README.md) | 🟡 | containerise an app with fast, cached builds |
| 04 | [Volumes & Networking](04-volumes-and-networking/README.md) | 🟡 | persistent data, backups, container-to-container DNS |
| 05 | [Docker Compose](05-docker-compose/README.md) | 🟡 | multi-service stacks, healthchecks, scaling behind nginx |
| 06 | [Production-ready Images](06-production-images/README.md) | 🔴 | multi-stage, non-root, hardening, scanning, CI builds |
| 07 | [Docker Capstone](07-capstone/README.md) | 🏆 | build → push → deploy → verify → auto-rollback |

## Docker cheat sheet

```bash
docker run -d --name web -p 127.0.0.1:8080:80 -e KEY=val -v data:/data --network appnet nginx:1.27-alpine
docker ps -a | docker logs -f web | docker exec -it web sh | docker inspect web | docker stats
docker stop web | docker start web | docker rm -f web
docker build -t app:1.0 . | docker tag app:1.0 reg/app:1.0 | docker push reg/app:1.0
docker volume ls | docker network ls | docker system df | docker system prune
docker compose up -d --build --wait | docker compose ps | docker compose logs -f | docker compose down [-v]
```

## 🏅 Docker expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain image vs container vs registry, layers, and why `latest` is dangerous
- [ ] Write a Dockerfile with good cache ordering, `.dockerignore`, exec-form `CMD`, `ARG` vs `ENV`
- [ ] Write a multi-stage build onto a slim/distroless base
- [ ] Run as a numeric non-root user with a `HEALTHCHECK`, and run locked down (`--read-only`, `--cap-drop ALL`)
- [ ] Choose named volumes vs bind mounts; back up and restore a volume
- [ ] Use user-defined networks and service-name DNS; publish only what must be reachable
- [ ] Write a Compose stack with healthchecks, `service_healthy` ordering, scaling and override files
- [ ] Explain PID 1 and signals, and why shell-form `CMD` breaks graceful shutdown
- [ ] Tag images with the git SHA, push to a registry from CI, and scan them for vulnerabilities
- [ ] Deploy with automatic rollback when health checks fail

👉 Start: [Module 01 — Containers & Your First `docker run`](01-containers-and-setup/README.md)
