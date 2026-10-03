# Ansible practice fleet

Three small Ubuntu 24.04 "servers" running in Docker, with **systemd**, **SSH (key-only)**, Python and a `devops`
user with passwordless `sudo` — just like fresh cloud VMs.

| Node | SSH | HTTP (if you install a web server) | Group |
|------|-----|-------------------------------------|-------|
| web1 | `127.0.0.1:2221` | http://localhost:8081 | `web` |
| web2 | `127.0.0.1:2222` | http://localhost:8082 | `web` |
| db1  | `127.0.0.1:2223` | http://localhost:8083 | `db` |

```bash
./fleet.sh up          # build + start (first time: a few minutes), creates .ssh/ lab key
./fleet.sh status
./fleet.sh ssh web1    # log in like a real server
./fleet.sh reset       # throw everything away and start clean (do this often!)
./fleet.sh down
```

Inventory: [`inventory.ini`](inventory.ini). The containers run `--privileged` so systemd works — fine for a local
lab, never do this in production.
