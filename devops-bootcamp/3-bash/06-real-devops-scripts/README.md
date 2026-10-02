# Bash Module 06 — Real DevOps Scripts 🔴

## 🎯 Objectives
Combine everything so far to build the scripts DevOps teams actually run:
- 🗄️ **Backup** with timestamps, checksums and retention
- 🔄 **Log rotation** (compress + delete old logs)
- ❤️ **HTTP health checks** with `curl`
- 👤 **User provisioning** from a CSV (with dry-run)
- 🚀 **Zero-downtime-style deploy** with release folders, a `current` symlink and **rollback**
- 🖥️ **Server bootstrap** (what goes in cloud-init / user-data)

## 🧠 Why DevOps engineers care
These are interview favourites and day-one tasks. Each script follows the same professional
skeleton, so once you've learned it you can produce reliable tools quickly.

---

## 📖 Lesson 6.1 — The professional script skeleton

```bash
#!/usr/bin/env bash
#
# name.sh — what it does
# Usage: name.sh [-n] [-v] ARGS
#
set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
DRY_RUN=false

log()  { printf '%s [%s] %s\n' "$(date '+%F %T')" "$SCRIPT_NAME" "$*" >&2; }
die()  { log "ERROR: $*"; exit 1; }
run()  {                                  # every state-changing command goes through run()
    if $DRY_RUN; then log "[dry-run] $*"; else "$@"; fi
}

usage() { sed -n '3,5p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

main() {
    [[ ${1:-} == "-n" ]] && { DRY_RUN=true; shift; }
    [[ $# -ge 1 ]] || usage
    run mkdir -p "$1"
}

main "$@"
```

Key ideas:
1. **Strict mode** + `die` for clear failures
2. **`run()` wrapper** → free `--dry-run` for every destructive step
3. **Logs to stderr** with timestamps (stdout stays clean for data)
4. **Validate inputs first**, then act
5. **Idempotent**: running it twice must be safe (`mkdir -p`, check-before-create)

## 📖 Lesson 6.2 — Backups

```bash
stamp=$(date +%Y%m%d-%H%M%S)
archive="/var/backups/etc-${stamp}.tar.gz"
tar -czf "$archive" -C / etc                         # -C: store relative paths
sha256sum "$archive" > "${archive}.sha256"           # integrity check
sha256sum -c "${archive}.sha256"                     # verify later

# keep newest 7
ls -1t /var/backups/etc-*.tar.gz | tail -n +8 | xargs -r rm -f
```

Database dumps follow the same pattern:
`pg_dump mydb | gzip > db-$stamp.sql.gz` · `mysqldump --single-transaction mydb | gzip > ...`

## 📖 Lesson 6.3 — Log rotation

```bash
find /var/log/myapp -name "*.log" -mtime +1 -exec gzip {} \;      # compress older than 1 day
find /var/log/myapp -name "*.log.gz" -mtime +30 -delete           # delete older than 30 days
```
On real servers use **logrotate** (`/etc/logrotate.d/myapp`) — but understanding the script version
helps you debug it.

## 📖 Lesson 6.4 — HTTP checks with curl

```bash
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 https://example.com)
time_total=$(curl -s -o /dev/null -w '%{time_total}' https://example.com)
curl -sf https://example.com/health > /dev/null && echo UP || echo DOWN    # -f: fail on 4xx/5xx
```

Notify Slack/Teams (webhook):
```bash
curl -s -X POST -H 'Content-Type: application/json' \
     -d "{\"text\": \"🚨 $service is DOWN\"}" "$SLACK_WEBHOOK_URL"
```

## 📖 Lesson 6.5 — Release folders + symlink deploys

```
/opt/myapp/
├── releases/
│   ├── 20240501-100000/
│   ├── 20240502-090000/
│   └── 20240503-143000/   ← new
└── current -> releases/20240503-143000    (symlink the web server points at)
```

```bash
ln -sfn "/opt/myapp/releases/$new" /opt/myapp/current     # switch is (almost) atomic
```
Rollback = point the symlink back to the previous release. That's how Capistrano, Deployer and
many in-house tools work.

## 📖 Lesson 6.6 — Idempotent server bootstrap

```bash
id deploy &>/dev/null || useradd -m -s /bin/bash deploy        # only if missing
grep -q '^PermitRootLogin no' /etc/ssh/sshd_config || \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
dpkg -s nginx &>/dev/null || apt-get install -y nginx
```

> 💡 When bootstrap scripts grow, that's the signal to move to **Ansible** — which you can now
> read and extend because you know Python and Bash!

---

## 🧪 Labs
Each lab has a full reference solution in [`solutions/`](solutions/). Try first!
Everything can be tested safely in a temp directory — no root needed (except Lab 4 for real).

### Lab 1 ⭐⭐ — `backup.sh`
`backup.sh [-n] [-k KEEP] SOURCE DEST` → `DEST/<name>-YYYYmmdd-HHMMSS.tar.gz` + `.sha256`,
verifies the checksum, keeps the newest `KEEP` (default 7), supports dry-run.

### Lab 2 ⭐⭐ — `rotate_logs.sh`
`rotate_logs.sh [-n] [-c DAYS] [-d DAYS] DIR` → gzip `*.log` older than `-c` days (default 1),
delete `*.gz` older than `-d` days (default 30), report space before/after.
Test with `touch -d '3 days ago' x.log`.

### Lab 3 ⭐⭐ — `http_check.sh`
Reads URLs from a file, checks each (status + time) **in parallel**, prints a table, optionally
posts failures to `$SLACK_WEBHOOK_URL`, exits 1 if any are down.

### Lab 4 ⭐⭐⭐ — `provision_users.sh`
Reads `users.csv` (`username,group,shell`). For each user: create the group if missing, create
the user if missing, set the shell. **Dry-run by default**; only changes things with `--apply`
(and must be root then). Fully idempotent.

### Lab 5 ⭐⭐⭐ — `deploy.sh` with rollback
`deploy.sh deploy SRC_DIR` / `deploy.sh rollback` / `deploy.sh list` over `APP_ROOT`
(default `/tmp/myapp`): copy into `releases/<timestamp>`, run a health check script if
present (`healthcheck.sh` inside the release), switch the `current` symlink only if healthy,
keep the 5 newest releases, and `rollback` to the previous one.

---

## ✅ Checkpoint
- [ ] My scripts have strict mode, logging, `die`, validation and dry-run
- [ ] My scripts are idempotent (safe to run twice)
- [ ] I can explain symlink-based deploys and rollback

👉 Next: [Module 07 — Pro Bash](../07-pro-bash/README.md)
