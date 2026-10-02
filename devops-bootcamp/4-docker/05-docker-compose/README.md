# Docker Module 05 — Docker Compose 🟡

## 🎯 Objectives
- Describe a multi-container app in one `compose.yaml`
- Start, stop, rebuild, scale and inspect it with `docker compose`
- Use healthchecks + `depends_on` so services start in the right order
- Manage configuration with `.env` files and override files
- Put nginx in front of several app replicas (a load balancer!)

## 🧠 Why DevOps engineers care
In Module 04 you needed a 40-line script to run two containers. Compose replaces that with a small
YAML file anyone can read and run with one command. Teams use it for local development, CI test
environments and small production deployments — and its concepts (services, networks, volumes,
health) map directly onto Kubernetes next.

---

## 📖 Lesson 5.1 — Your first `compose.yaml`

```yaml
# compose.yaml
services:
  redis:
    image: redis:7-alpine
    volumes:
      - redisdata:/data

  app:
    build: ./app                 # build from ./app/Dockerfile
    image: demo-app:compose      # name the built image
    environment:
      REDIS_HOST: redis          # service name = DNS name
    ports:
      - "127.0.0.1:8000:8000"
    depends_on:
      - redis

volumes:
  redisdata:
```

```bash
docker compose up -d            # build if needed, create network + volume, start everything
docker compose ps               # status
curl localhost:8000/visits
docker compose logs -f app      # follow one service's logs
docker compose down             # stop and remove containers + network (volumes are KEPT)
docker compose down -v          # ...and delete the volumes too (data gone!)
```

Compose automatically creates a network `<folder>_default` — every service can reach every other
**by its service name**.

## 📖 Lesson 5.2 — Everyday commands

| Command | What it does |
|---------|--------------|
| `docker compose up -d` | create/update and start everything in the background |
| `docker compose up -d --build` | rebuild images first (after code changes) |
| `docker compose ps` | list the services' containers |
| `docker compose logs -f [svc]` | follow logs |
| `docker compose exec app sh` | shell inside a running service |
| `docker compose run --rm app python3 -V` | one-off command in a new container |
| `docker compose restart app` | restart a service |
| `docker compose stop` / `start` | stop/start without removing |
| `docker compose down [-v]` | remove containers + network [+ volumes] |
| `docker compose config` | print the final, merged config (great for debugging YAML) |
| `docker compose pull` | pull newer images |

## 📖 Lesson 5.3 — Healthchecks and startup order

`depends_on` alone only waits for the container to **start**, not for the app inside to be **ready**.
Add a healthcheck and wait for `service_healthy`:

```yaml
services:
  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  app:
    build: ./app
    depends_on:
      redis:
        condition: service_healthy     # wait until redis's healthcheck passes
    healthcheck:
      test: ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
```

`docker compose ps` now shows `(healthy)` / `(unhealthy)`.

## 📖 Lesson 5.4 — Configuration: `.env`, `env_file`, variables

`.env` (next to `compose.yaml`, loaded automatically — **add it to `.gitignore`**):
```
APP_VERSION=1.2.0
APP_PORT=8000
```

```yaml
services:
  app:
    image: demo-app:${APP_VERSION:-dev}        # ${VAR:-default} works like in shell
    ports:
      - "127.0.0.1:${APP_PORT:-8000}:8000"
    env_file:
      - app.env                                # pass many variables into the container
    environment:
      APP_VERSION: ${APP_VERSION:-dev}
```

Check what Compose will actually use: `docker compose config`.

## 📖 Lesson 5.5 — Scaling and load balancing

```bash
docker compose up -d --scale app=3     # three app containers
```
You can't publish the same host port 3 times, so put **nginx** in front:

```yaml
  proxy:
    image: nginx:1.27-alpine
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      app:
        condition: service_healthy
```

`nginx.conf`:
```nginx
server {
    listen 80;
    location / {
        proxy_pass http://app:8000;     # Docker DNS returns ALL app replicas → nginx spreads requests
    }
}
```
```bash
for i in $(seq 6); do curl -s localhost:8080/ | grep -o '"hostname": "[^"]*"'; done   # different hostnames!
```

## 📖 Lesson 5.6 — Override files: dev vs prod

Compose merges `compose.yaml` + `compose.override.yaml` automatically. Use that for **development-only**
settings, and pick other files explicitly with `-f`:

```yaml
# compose.override.yaml  (dev only: live code reload via bind mount, debug logging)
services:
  app:
    volumes:
      - ./app/app.py:/app/app.py:ro
    environment:
      LOG_LEVEL: debug
```
```bash
docker compose up -d                                         # base + override (dev)
docker compose -f compose.yaml -f compose.prod.yaml up -d    # base + prod (override ignored)
```

**Profiles** — optional services you only start sometimes:
```yaml
  redis-ui:
    image: redis/redisinsight:latest
    profiles: ["debug"]
```
```bash
docker compose --profile debug up -d
```

## 📖 Lesson 5.7 — Restart policies and resources

```yaml
  app:
    restart: unless-stopped        # no | always | on-failure | unless-stopped
    deploy:
      resources:
        limits:
          cpus: "0.50"
          memory: 256M
```

---

## ⚠️ Common mistakes
- Using `localhost` to reach another service — inside a container, `localhost` is **that container**. Use the service name
- `depends_on` without a healthcheck and expecting the DB to be ready
- `docker compose down -v` by habit → database gone
- Committing `.env` with secrets
- Forgetting `--build` after changing code (the old image keeps running)
- YAML indentation errors → run `docker compose config`

---

## 🧪 Labs
The full reference stack is in [`solutions/`](solutions/) (`compose.yaml`, `nginx.conf`, override, prod file,
and `smoke_test.sh`).

### Lab 1 ⭐ — Two services
Write a `compose.yaml` for demo-app (built from a Dockerfile) + Redis with a named volume. Bring it up,
hit `/visits` a few times, `down`, `up` again — the count continues. Then `down -v` and see it reset.

### Lab 2 ⭐⭐ — Healthy startup
Add healthchecks to both services and `condition: service_healthy`. Show `(healthy)` in `docker compose ps`.
Break the app healthcheck on purpose (wrong path) and watch it become `unhealthy`.

### Lab 3 ⭐⭐ — Load balancer
Add nginx as a reverse proxy on `127.0.0.1:8080`, scale the app to 3 replicas, and prove with a loop of
`curl` requests that different containers answer. Remove the app's own `ports:` — only nginx is published.

### Lab 4 ⭐⭐⭐ — Dev vs prod + smoke test
Add `compose.override.yaml` (bind-mount the code, `APP_MESSAGE` says "DEV") and `compose.prod.yaml`
(`restart: unless-stopped`, resource limits, `APP_MESSAGE` says "PROD"). Write `smoke_test.sh` that
brings a stack up, waits for health, checks `/`, `/health` and `/visits` through nginx, and exits non-zero
on any failure — the kind of script a CI pipeline runs.

---

## ✅ Checkpoint
- [ ] I can write a compose file with services, volumes, env, ports and healthchecks
- [ ] I use service names (not `localhost`) between containers
- [ ] I can scale a service behind nginx
- [ ] I know what `down` vs `down -v` deletes

👉 Next: [Module 06 — Production-ready Images](../06-production-images/README.md)
