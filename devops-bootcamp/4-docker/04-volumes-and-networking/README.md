# Docker Module 04 — Volumes & Networking 🟡

## 🎯 Objectives
- Keep data safe when containers are deleted: **named volumes** and **bind mounts**
- Back up and restore a volume
- Connect containers with **user-defined networks** and Docker's built-in DNS
- Publish ports safely (and only where needed)
- Run a two-container app (demo-app + Redis) by hand

## 🧠 Why DevOps engineers care
Containers are **disposable** — you delete and replace them on every deploy. Databases, uploads and
config must live somewhere that survives that. And real apps are several containers talking to each
other: you need to know how they find each other and what's exposed to the outside world.

---

## 📖 Lesson 4.1 — Where can container data live?

| Type | Syntax | Lives in | Use for |
|------|--------|----------|---------|
| Container layer | (default) | the container — **deleted with it** | nothing important |
| **Named volume** | `-v pgdata:/var/lib/postgresql/data` | Docker-managed area (`/var/lib/docker/volumes/`) | databases, persistent app data |
| **Bind mount** | `-v "$PWD/site":/usr/share/nginx/html` | a folder on your host | config files, live-editing code in development |
| tmpfs | `--tmpfs /tmp` | memory | scratch space, secrets that must not touch disk |

> The newer, more explicit `--mount` syntax does the same thing:
> `--mount type=volume,source=pgdata,target=/var/lib/postgresql/data`

## 📖 Lesson 4.2 — Named volumes

```bash
docker volume create appdata
docker run --rm -v appdata:/data alpine:3.20 sh -c 'echo "saved at $(date)" > /data/note.txt'
docker run --rm -v appdata:/data alpine:3.20 cat /data/note.txt     # still there — new container!
docker volume ls
docker volume inspect appdata          # Mountpoint: /var/lib/docker/volumes/appdata/_data
docker volume rm appdata               # only when no container uses it
docker volume prune                    # remove ALL unused volumes (careful — this is your data!)
```

A real database:
```bash
docker run -d --name redis -v redisdata:/data redis:7-alpine redis-server --appendonly yes
docker exec redis redis-cli SET greeting "hello"
docker rm -f redis                                         # container gone...
docker run -d --name redis -v redisdata:/data redis:7-alpine redis-server --appendonly yes
docker exec redis redis-cli GET greeting                   # "hello" — data survived ✅
```

## 📖 Lesson 4.3 — Bind mounts

```bash
mkdir -p site && echo "<h1>Hello from my laptop</h1>" > site/index.html
docker run -d --name web -p 8080:80 -v "$PWD/site":/usr/share/nginx/html:ro nginx:1.27-alpine
curl localhost:8080
echo "<h1>Edited live!</h1>" > site/index.html
curl localhost:8080          # changes appear instantly — no rebuild
```
- `:ro` = read-only inside the container (use it whenever the container shouldn't write)
- Bind mounts depend on the host's folder layout → great for development, used less in production

## 📖 Lesson 4.4 — Back up and restore a volume

There's no `docker volume backup` command. The trick: run a throwaway container that mounts the
volume **and** a host folder, and use `tar`:

```bash
# backup  redisdata → ./backups/redisdata-<date>.tar.gz
mkdir -p backups
docker run --rm -v redisdata:/source:ro -v "$PWD/backups":/backup alpine:3.20 \
    tar -czf "/backup/redisdata-$(date +%F).tar.gz" -C /source .

# restore into a NEW volume
docker volume create redisdata-restored
docker run --rm -v redisdata-restored:/target -v "$PWD/backups":/backup alpine:3.20 \
    tar -xzf "/backup/redisdata-$(date +%F).tar.gz" -C /target
```

## 📖 Lesson 4.5 — Networks

```bash
docker network ls          # bridge (default), host, none
```

| Network | Behaviour |
|---------|-----------|
| default `bridge` | containers get an IP but **no DNS by name** |
| **user-defined bridge** ✅ | containers find each other **by container name** (built-in DNS) |
| `host` | the container uses the host's network directly (no isolation, no `-p` needed) |
| `none` | no network at all |

```bash
docker network create appnet
docker run -d --name redis --network appnet redis:7-alpine
docker run --rm --network appnet alpine:3.20 ping -c 2 redis      # resolves the name "redis" ✅
docker network inspect appnet                                    # who's connected
docker network connect appnet some-other-container               # attach a running container
```

## 📖 Lesson 4.6 — Two containers working together

```bash
docker network create appnet
docker run -d --name redis --network appnet -v redisdata:/data redis:7-alpine
docker run -d --name demo --network appnet -p 8000:8000 \
    -e REDIS_HOST=redis demo-app:1.0.0             # "redis" = the container name = DNS name
curl localhost:8000/visits      # {"visits": 1, "backend": "redis", ...}
curl localhost:8000/visits      # 2 — stored in Redis
docker rm -f demo && docker run -d --name demo --network appnet -p 8000:8000 -e REDIS_HOST=redis demo-app:1.0.0
curl localhost:8000/visits      # 3 — the count survived replacing the app container
```

Notice: Redis has **no** `-p` — only demo-app can reach it, through `appnet`. Nothing from outside can.

## 📖 Lesson 4.7 — Publishing ports safely

```bash
-p 8080:80                # listens on ALL host interfaces → reachable from your network/internet
-p 127.0.0.1:8080:80      # ✅ only from this machine (perfect for admin UIs, databases in dev)
-P                        # publish every EXPOSEd port on random host ports
docker port demo          # show the mappings
```

> 🔐 Docker's port publishing adds firewall (iptables) rules that can **bypass `ufw`**. Never publish
> a database port on a server unless you mean to — keep it on an internal network instead.

---

## ⚠️ Common mistakes
- Storing database data in the container layer → gone on `docker rm`
- `docker volume prune` / `docker system prune --volumes` without thinking → data loss
- Expecting containers on the **default** bridge to resolve each other by name
- Publishing database ports to `0.0.0.0` on a server
- Relative paths in `-v ./site:/...` with older Docker versions — use `"$PWD/site"`

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Build `demo-app:1.0.0` first (Module 03 Lab 2).

### Lab 1 ⭐ — Prove persistence
Write a value into Redis with a named volume, delete the container, start a new one with the same
volume and read the value back. Then do the same **without** a volume and see it's lost.

### Lab 2 ⭐⭐ — Live website
Serve a `site/` folder with nginx using a read-only bind mount on `127.0.0.1:8080`. Edit the page and
watch it change. Try to write into the folder from inside the container — what happens and why?

### Lab 3 ⭐⭐ — Volume backup & restore script
`volume_backup.sh backup VOLUME DIR` and `volume_backup.sh restore ARCHIVE VOLUME` using throwaway
`alpine` containers and `tar`. Prove it works with the Redis volume from Lab 1.

### Lab 4 ⭐⭐⭐ — Two-tier app by hand
Script `two_tier.sh up|down|status`: `up` creates network `appnet`, a Redis container with a volume
(no published port) and demo-app on `127.0.0.1:8000` with `REDIS_HOST=redis`; waits for `/health`;
`status` shows both containers and the visit count; `down` removes containers and network but **keeps**
the volume. Run `up`, hit `/visits` 3 times, `down`, `up`, and show the count continued.

---

## ✅ Checkpoint
- [ ] I know when to use a named volume vs a bind mount
- [ ] I can back up and restore a volume with a throwaway container
- [ ] I use user-defined networks so containers find each other by name
- [ ] I only publish the ports that must be reachable, preferring `127.0.0.1:`

👉 Next: [Module 05 — Docker Compose](../05-docker-compose/README.md)
