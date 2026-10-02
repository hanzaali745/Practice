# Module 14 — Python Capstone Projects 🏆

> **CEO note:** This is your portfolio. Build each project in its own folder (or repo),
> with a README, `requirements.txt`, tests, and a CI workflow. In interviews, you'll
> walk through *these* — not tutorial exercises.

Every project must meet the **Definition of Done**:
- [ ] `argparse` CLI with `--help`, sensible defaults
- [ ] `logging` with `-v/--verbose`
- [ ] Config via file and/or env vars (no secrets in code)
- [ ] Correct exit codes (0 OK, non-zero on failure)
- [ ] `--dry-run` for anything that changes state
- [ ] Unit tests (pytest) for the core logic
- [ ] `ruff` clean; type hints on functions
- [ ] README with usage examples

---

## Project 1 ⭐⭐ — `healthmon`: Infrastructure Health Monitor (full reference solution)

A tool that reads a YAML list of targets and checks them all:

```yaml
# targets.yaml
targets:
  - name: google
    type: http
    url: https://www.google.com
    expect_status: 200
  - name: local-ssh
    type: tcp
    host: localhost
    port: 22
  - name: root-disk
    type: disk
    path: /
    max_percent: 90
```

```bash
./healthmon.py targets.yaml                # pretty table
./healthmon.py targets.yaml --json         # machine-readable for other tools
./healthmon.py targets.yaml -v; echo $?    # exit 0 if all OK, 1 if any failed, 2 on bad config
```

Features: HTTP checks (status + latency), TCP port checks, disk usage checks,
parallel checks with `concurrent.futures.ThreadPoolExecutor`, table or JSON output.

👉 Reference: [`solutions/healthmon/`](solutions/healthmon/) — run `pytest` inside it.

**Stretch goals:** Slack webhook alert on failure · run every minute via cron/systemd timer ·
Dockerfile · expose results as a `/metrics` endpoint (Module 12).

---

## Project 2 ⭐⭐ — `logwatch`: Log Analyzer & Alerter
Build a CLI that:
- accepts one or more log files (support `.gz` with the `gzip` module)
- parses nginx/apache access logs with regex (Module 11)
- reports top IPs, top paths, status code breakdown, requests per minute
- `--since "2024-05-01 10:00"` time filter (`datetime.strptime`)
- `--alert-5xx-rate 5` → exit code 2 if more than 5% of requests are 5xx
- `--format table|json|csv`

**Hints:** `collections.Counter`, generator functions to stream huge files, `gzip.open(path, "rt")`.

---

## Project 3 ⭐⭐⭐ — `backupctl`: Backup & Retention Manager
- `backupctl create --source /etc --dest /backups` → timestamped `.tar.gz` + `.sha256` checksum (`hashlib`)
- `backupctl verify FILE` → re-check the checksum
- `backupctl prune --keep-daily 7 --keep-weekly 4` → retention policy
- `backupctl upload --bucket my-bucket` → S3 via `boto3` (optional)
- Uses argparse **subcommands** (`parser.add_subparsers()`)

---

## Project 4 ⭐⭐⭐ — `deployer`: Git + Docker Deploy Helper
- Reads `deploy.yaml` (app name, git repo, image name, port, env vars, health URL)
- Steps: `git pull` → `docker build -t app:<git-sha>` → stop old container → run new one →
  poll health URL with retries → **auto-rollback** to previous image if unhealthy
- Every step logged; `--dry-run` prints the commands instead of running them
- All shell commands through one `run(cmd: list[str])` helper using `subprocess.run(check=True, timeout=...)`

---

## Project 5 ⭐⭐⭐ — `cloudaudit`: AWS Cost & Security Auditor (needs AWS free tier)
- Lists EC2 instances without an `Owner` tag, unattached EBS volumes, unused Elastic IPs,
  public S3 buckets, security groups open to `0.0.0.0/0` on port 22
- Outputs a Markdown report
- Bonus: run on a schedule in GitHub Actions using OIDC (no stored keys)

---

## 🎓 You've finished Python!
You can now automate files, processes, APIs and the cloud, and write tested, production-grade tools.

👉 Next phase: [Shell Script & Bash](../../bash/README.md)
