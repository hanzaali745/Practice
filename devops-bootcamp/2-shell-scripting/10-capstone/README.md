# Shell Module 10 — Shell Scripting Capstone 🏆

> **CEO note:** These projects must run with `#!/bin/sh` — in Ubuntu's `dash` **and** in an Alpine
> container. That's real-world portability, and it proves you understand the shell itself, not
> just Bash.

**Definition of Done** for every project:
- [ ] `#!/bin/sh`, `set -eu`, header comment with usage
- [ ] Usage message on bad input (exit 2), `die` helper (exit 1)
- [ ] All variables quoted, functions + `main "$@"`
- [ ] `trap` cleanup for anything temporary
- [ ] `shellcheck -s sh` shows **zero** warnings; runs with `dash`
- [ ] A short README with examples

---

## Project 1 ⭐⭐⭐ — `docker-entrypoint.sh` (full reference solution)

Nearly every production Docker image has an entrypoint script. Yours must:

1. **Validate** required environment variables (`APP_ENV`, `DB_HOST`) — fail clearly if missing
2. **Wait** for the database port to open (with a timeout) using `nc`
3. **Render** a config file from a template, replacing `${VAR}` placeholders with env values
4. **Run** the real program with `exec "$@"` so it becomes PID 1 and receives `docker stop` signals

```sh
APP_ENV=prod DB_HOST=localhost DB_PORT=5432 \
  sh docker-entrypoint.sh python3 -m http.server 8080
```

👉 Reference: [`solutions/docker-entrypoint.sh`](solutions/docker-entrypoint.sh),
template [`solutions/app.conf.template`](solutions/app.conf.template),
tests [`solutions/test_entrypoint.sh`](solutions/test_entrypoint.sh) (run `sh test_entrypoint.sh`).

Try it in a real container (if you have Docker):
```sh
cd solutions
docker run --rm -v "$PWD:/app" -w /app -e APP_ENV=dev -e DB_HOST=example.com -e DB_PORT=80 \
    alpine sh docker-entrypoint.sh cat /tmp/app.conf
```

---

## Project 2 ⭐⭐ — `sysinfo.sh`: Portable System Report as JSON
Print a JSON object with hostname, OS, kernel, uptime seconds, CPU count, load average,
memory and disk usage — **without** `jq` (build the JSON with `printf`). Validate the output with
`sh sysinfo.sh | jq .`. Monitoring agents use output like this.

## Project 3 ⭐⭐ — `logclean.sh`: Log Janitor for cron
`logclean.sh [-n] [-c DAYS] [-d DAYS] DIR` — gzip `*.log` older than `-c` days, delete `*.gz`
older than `-d` days, print a summary. Use POSIX `getopts` (yes, `getopts` is POSIX!), a `flock`
lock and a dry-run mode. Install it in cron to run nightly.

## Project 4 ⭐⭐⭐ — `install.sh`: One-line Installer
The kind of script people run with `curl -fsSL https://.../install.sh | sh`:
detect OS and CPU architecture (`uname -s`, `uname -m`), download the right binary with `curl`,
verify its SHA-256 checksum, install to `/usr/local/bin` (or `~/.local/bin` without root),
and print the installed version. Never leave half-installed files (use `trap`).

---

## 🎓 Shell phase complete!

Go back to the [expert checklist](../README.md#-shell-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes)
and tick every item. Then move on.

👉 Next phase: [Phase 3 — Bash](../../3-bash/README.md)
