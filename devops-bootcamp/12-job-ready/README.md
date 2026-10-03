# 💼 Phase 12: Job-ready — Troubleshooting, Git for Teams & Interviews

> **Before you start:** finish Phases 1–11 (Module 03 only needs Git, so you can do it earlier if you like).
> **It's free and local:** a containerised Ubuntu server that breaks on demand ([`lab/`](lab/)), a Git scenario
> generator, and interview material with tested solutions. Install the Part 3 Python packages
> (`pip install -r requirements-platform.txt` — it now includes `git-filter-repo` and `pre-commit`).

The first eleven phases taught you the tools. This phase trains what turns that into a job: staying systematic when
things break, working in a shared repository without fear, and showing all of it in an interview.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Linux Troubleshooting](01-linux-troubleshooting/README.md) | 🟡 | a method, first-60-seconds checks, systemd, CPU/memory/disk/inodes, permissions |
| 02 | [Networking Troubleshooting](02-networking-troubleshooting/README.md) | 🟡 | layer by layer: DNS vs /etc/hosts, refused vs timeout, curl, TLS, firewalls |
| 03 | [Git for Teams](03-git-for-teams/README.md) | 🟡 | rebase and conflicts, clean history, reflog, bisect, revert, hotfixes, leaked secrets |
| 04 | [Incident Practice](04-incident-practice/README.md) | 🔴 | random timed incidents, two-cause incidents, communication, blameless postmortems |
| 05 | [Interview Prep](05-interview-prep/README.md) | 🏆 | 75 questions, system design, live coding, STAR stories, CV and portfolio |

## The two labs

```bash
cd ~/Practice/devops-bootcamp/12-job-ready
lab/lab.sh list                          # 12 server scenarios + 3 two-cause incidents
lab/lab.sh break dns && lab/lab.sh shell # fix it... then: lab/lab.sh check
lab/lab.sh incident                      # a random page, timed
03-git-for-teams/git-lab.sh list         # 7 team Git situations
```

## Cheat sheet

```bash
uptime; dmesg -T | tail; systemctl --failed; free -h; vmstat 1 5; ps aux --sort=-%cpu | head; df -h; df -i; iostat -xz 1
systemctl status|cat|show -p Environment SVC; journalctl -u SVC -n 50 --no-pager; systemctl daemon-reload
lsof -a +L1 /mount; namei -l /path/to/file; sudo -u USER test -r FILE; crontab -l; ls /etc/cron.d; systemctl list-timers
getent hosts NAME; dig NAME +short; ss -tlnp; nc -vz -w3 HOST PORT; curl -v -w '%{time_total}\n' URL
openssl s_client -connect HOST:443 -servername HOST </dev/null | openssl x509 -noout -subject -ext subjectAltName -dates
iptables -L OUTPUT -n -v --line-numbers; tcpdump -ni any port 6379
git fetch && git rebase origin/main; git push --force-with-lease; git reflog; git bisect run ./test.sh
git revert -m 1 MERGE; git cherry-pick -x SHA; git tag -a v1.2.3 -m msg; git filter-repo --invert-paths --path FILE
```

## 🏅 Job-ready expert checklist

You're ready when you can do all of these **without notes**:

- [ ] Troubleshoot a sick Linux server with a method, explaining each step out loud
- [ ] Debug services, CPU, memory, disk, inode, deleted-file and permission problems — and fix the cause, not the symptom
- [ ] Debug a connection layer by layer and say which layer is broken (name, route, port, TLS, HTTP)
- [ ] Work in a team repository: rebase through conflicts, clean up history, recover lost work, bisect, revert, hotfix
- [ ] Handle a leaked secret in the right order (rotate first)
- [ ] Run an incident: impact, severity, mitigate first, status updates — and write a blameless postmortem
- [ ] Answer the common DevOps interview questions with examples from your own projects
- [ ] Lead a system design discussion and solve a practical coding task with tests
- [ ] Show a GitHub portfolio and CV you're proud of — and apply

👉 Start: [Module 01 — Linux Troubleshooting](01-linux-troubleshooting/README.md)
