# Bash Module 08 — Bash Capstone Projects 🏆

> **CEO note:** Same deal as the Python capstone: put each project in your GitHub with a README,
> ShellCheck-clean code, Bats tests and a CI workflow. These are what you show in interviews.

**Definition of Done** for every project:
- [ ] `#!/usr/bin/env bash` + `set -euo pipefail`, header comment with usage
- [ ] Option parsing (`getopts` or long options) with `-h/--help`
- [ ] Functions + `main "$@"`; `local` everywhere
- [ ] Logging to stderr with timestamps; meaningful exit codes
- [ ] `--dry-run` for destructive actions; idempotent
- [ ] `trap` cleanup; `flock` if it may run from cron
- [ ] ShellCheck clean; Bats tests; CI workflow

---

## Project 1 ⭐⭐⭐ — `opsctl`: Ops Toolkit (full reference solution)

One command, several subcommands, a shared library — like `git` or `kubectl`:

```bash
./opsctl help
./opsctl health                       # disk / memory / load / services → exit 0/1
./opsctl health -s sshd -s cron       # also check processes
./opsctl logs-report access.log       # top IPs, status codes, error rate
./opsctl backup -k 5 /etc/nginx /var/backups
./opsctl cleanup -d 7 -p '*.log' /var/log/myapp -n   # dry-run
```

```
opsctl/
├── opsctl                # entrypoint: parses subcommand, dispatches
├── lib/
│   ├── common.sh         # log, die, run (dry-run), require_cmd
│   ├── health.sh
│   ├── logs.sh
│   ├── backup.sh
│   └── cleanup.sh
└── tests/
    └── opsctl.bats
```

👉 Reference: [`solutions/opsctl/`](solutions/opsctl/) — run `bats tests/` inside it.

**Stretch goals:** `opsctl health --json` · Slack alerts · install script that copies it to
`/usr/local/bin` + bash completion · systemd timer running `opsctl health` every 5 minutes.

---

## Project 2 ⭐⭐ — `server-audit.sh`: Security & Compliance Audit
Check a Linux server and produce a Markdown report:
- users with UID 0 besides root, users with empty passwords (`/etc/shadow`, needs root)
- `PermitRootLogin` / `PasswordAuthentication` in `sshd_config`
- world-writable files in `/etc`, SUID binaries (`find / -perm -4000`)
- listening ports (`ss -tlnp`), firewall status, pending security updates
- score: PASS/WARN/FAIL per check, exit non-zero if any FAIL

---

## Project 3 ⭐⭐⭐ — `docker-deploy.sh`: Container Deploy with Rollback
- `deploy IMAGE:TAG` → pull, stop old container (keep it), start new on the same port,
  wait for `/health` with retries, **roll back** to the old container if unhealthy
- `status`, `logs`, `rollback` subcommands
- Remembers the previous tag in a state file; `flock` so two deploys never overlap

---

## Project 4 ⭐⭐⭐ — `k8s-helper.sh`: kubectl Productivity Wrapper
(needs `kubectl` + a cluster like `kind`/`minikube`)
- `pods-not-ready [-n NS]` (use `kubectl get pods -o json | jq`)
- `restart-count` → pods sorted by restarts
- `logs-errors DEPLOYMENT` → last 500 log lines filtered for ERROR from all pods
- `image-report` → every image:tag running, flag `:latest`

---

## Project 5 ⭐⭐⭐⭐ — Combine Python + Bash
Write a Bash **wrapper** that bootstraps a venv, installs requirements and runs your Python
`healthmon` (Python Module 15) on a schedule via a systemd timer — with logs in `journalctl`.
This is exactly how many real internal tools are shipped.

---

## 🎓 Congratulations — you've completed the scripting half of the bootcamp!

You can now:
- ✅ Write Python automation: files, processes, APIs, cloud, tests, CI
- ✅ Write production-grade Bash: strict mode, traps, getopts, ShellCheck, Bats
- ✅ Choose the right tool for each job

**Next on my team: the platform tools.** Install them first with
[Setup part 2](../../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md) (Day 124), then:
1. [Phase 4 — Docker](../../4-docker/README.md)
2. [Phase 5 — Kubernetes](../../5-kubernetes/README.md)
3. [Phase 6 — Terraform](../../6-terraform/README.md)
4. [Phase 7 — Ansible](../../7-ansible/README.md)

👉 Next phase: [Phase 4 — Docker](../../4-docker/README.md)
