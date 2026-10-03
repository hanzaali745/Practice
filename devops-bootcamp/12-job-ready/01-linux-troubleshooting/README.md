# Job-ready Module 01 — Linux Troubleshooting 🟡

## 🎯 Objectives
- Troubleshoot with a **method** instead of guessing: observe → hypothesise → test → fix → verify → write it down
- Run the "first 60 seconds" checks on any Linux server, and know what each number means
- Debug services with `systemctl` and `journalctl`, including drop-in overrides and restart loops
- Find what eats CPU, memory, disk space and inodes — and what keeps it coming back
- Fix permission problems properly (least privilege, never `chmod 777`)
- Practise on a real (containerised) Ubuntu server that breaks on demand

## 🧠 Why DevOps engineers care
Everything you built in this bootcamp eventually runs on a Linux machine — a VM, a Kubernetes node, a container. When it
breaks at 3 a.m., tools don't fix it; a calm, systematic engineer does. "Walk me through how you'd debug a slow server"
is the most common DevOps interview question there is, and this module is the answer.

---

## 🧪 The lab server (used in Modules 01, 02 and 04)

```bash
cd ~/Practice/devops-bootcamp/12-job-ready/lab
./lab.sh list                 # the scenarios and the alert each one gives you
./lab.sh break service-crash  # a fresh server, then something breaks
./lab.sh shell                # log in as the on-call user (sudo works)
./lab.sh hint                 # up to 3 hints, one at a time
./lab.sh check                # fixed — properly? (it checks the root cause, not just the symptom)
./lab.sh down                 # stop it when you're done
```
`web-1` is Ubuntu 24.04 with systemd: **nginx** on :80 → **demo-app** (a systemd service, user `demo`, port 8000) →
**Redis**. It's reachable from your laptop at http://localhost:8080. The first `break` builds the image (a few minutes).

**Rules:** don't read the scenario's `break.sh` or this module's `solutions/` before you've fixed it — the alert is all
you get in real life. Write down what you checked and why; that becomes your postmortem (Module 04).

---

## 📖 Lesson 1.1 — A method beats a hunch

1. **Observe.** What exactly is broken, for whom, since when? What changed? (Deploys, config runs, cron jobs, people.)
2. **Hypothesise.** Name one possible cause, based on evidence.
3. **Test** it with a command that can prove you *wrong*.
4. **Fix** the cause — the smallest change that does it. Then **verify** from the user's side.
5. **Write it down**: timeline, cause, fix, and what stops it happening again.

Work from the outside in (the user's symptom → load balancer → web server → app → its dependencies) and from cheap
to expensive checks. Change **one** thing at a time, and keep notes as you go.

## 📖 Lesson 1.2 — The first 60 seconds

| Command | You're looking for |
|---------|--------------------|
| `uptime` | load average vs `nproc`: a load above the CPU count means work is queueing |
| `dmesg -T \| tail` / `journalctl -k` | OOM kills, disk errors, network link flaps |
| `systemctl --failed` | services that died |
| `free -h` | **available** memory (not "free" — Linux uses spare RAM as cache), swap in use |
| `vmstat 1 5` | `r` (runnable) > CPUs = CPU-bound; `wa` high = waiting on disk; `si/so` ≠ 0 = swapping |
| `ps aux --sort=-%cpu \| head` | who uses the CPU |
| `df -h` and `df -i` | full file systems — space **and** inodes |
| `iostat -xz 1` | `%util` near 100 = the disk is saturated |
| `ss -tlnp` | what listens where |
| `journalctl -p err --since -15min` | recent errors from anything |

[`solutions/first60.sh`](solutions/first60.sh) runs all of these and saves one report for the ticket.

## 📖 Lesson 1.3 — Services: systemctl & journalctl

```bash
systemctl status demo-app              # state, main PID, last log lines, how often it restarted
systemctl cat demo-app                 # the unit file PLUS every drop-in (/etc/systemd/system/demo-app.service.d/*.conf)
systemctl show -p Environment,User,NRestarts demo-app   # the EFFECTIVE values after all overrides
sudo systemctl edit demo-app           # the right way to override: creates a drop-in
sudo systemctl daemon-reload           # after editing unit files by hand — otherwise systemd uses the old version
journalctl -u demo-app -n 50 --no-pager           # this service's logs
journalctl -u demo-app --since "10 min ago" -f    # follow
journalctl -b -p warning               # this boot, warnings and worse
```
A service stuck in `activating (auto-restart)` is crash-looping: `Restart=on-failure` keeps restarting it. The reason
is almost always in the first lines of its log after a start.

## 📖 Lesson 1.4 — CPU and processes

- **Load average** counts processes running *or waiting* (for CPU, and on Linux also for disk). Compare it to `nproc`.
- `top` → `P` sort by CPU, `M` by memory, `c` full commands, `1` per-CPU. `htop` is friendlier.
- Who started it? `ps -o pid,ppid,user,lstart,cmd -p PID`, and `systemctl status PID` shows the owning unit.
- What is it doing? `strace -p PID -f -e trace=file,network` (system calls), `ls -l /proc/PID/fd` (open files).
- **Signals:** `kill PID` (TERM: please stop) → wait → `kill -9 PID` (KILL: can't be ignored, no clean-up).
- Scheduled work hides in `/etc/cron.d/`, `/etc/crontab`, `crontab -l -u USER` and `systemctl list-timers`.
  If something "comes back" after you kill it, look there (or at `Restart=`).

## 📖 Lesson 1.5 — Memory

- `free -h`: **available** is what matters. Low available + swap in use + `si/so` in `vmstat` = memory pressure.
- When memory runs out, the kernel's **OOM killer** kills a process: `dmesg -T | grep -i "out of memory"`,
  `journalctl -k | grep -i oom`. The service then "randomly" restarts — check this first.
- Per process: `ps aux --sort=-%mem | head`; RSS is real memory in use. In containers and services, limits come from
  cgroups (`systemctl show -p MemoryMax demo-app`, Kubernetes `resources.limits`).

## 📖 Lesson 1.6 — Disks: space, inodes, deleted files, IO

| Symptom | Check | Typical cause |
|---------|-------|---------------|
| `df -h` 100% | `du -sh /var/log/* \| sort -h`, `ncdu /` | logs without rotation, old releases, Docker images (`docker system df`) |
| `df -i` 100% (space free!) | `find DIR -xdev -type f \| cut -d/ -f1-4 \| sort \| uniq -c \| sort -n` | millions of tiny files (sessions, caches, mail queues) |
| `df` full but `du` isn't | `lsof +L1` | a **deleted file still open** by a process — space returns when it closes |
| everything slow | `iostat -xz 1`, `vmstat` `wa` | a saturated disk |

Fix the space now (delete, compress, archive), then fix the **policy** (logrotate: `rotate`, `compress`, `maxsize`)
so it doesn't happen again.

## 📖 Lesson 1.7 — Permissions

```bash
namei -l /opt/demo-app/app.py          # permissions of EVERY directory on the path (each needs x to pass through)
sudo -u demo cat /opt/demo-app/app.py  # test as the service's user, not as root
stat -c '%A %U:%G %n' FILE             # mode, owner, group
```
Give the service user the minimum: code **readable** (owned by root, group = service user, mode 640/644),
directories **enterable** (755/750), only data/log directories **writable**. `chmod 777` "works" — and lets any
compromised process rewrite your code. On RHEL-family systems also check SELinux (`getenforce`, `ausearch -m avc`).

---

## ⚠️ Common mistakes
- Restarting things until it works, without knowing why — it will be back, and you'll have no postmortem
- Fixing the symptom (delete logs, kill the process) and not the cause (rotation policy, the cron entry)
- Editing a unit file and forgetting `systemctl daemon-reload`
- Reading `free` instead of `available`; panicking about "high memory use" that is just cache
- `chmod -R 777` or running the service as root "to make it work"
- Changing several things at once, so you never learn which one fixed it

---

## 🧪 Labs
Every lab: `./lab.sh break NAME`, investigate as `./lab.sh shell`, then `./lab.sh check`. Write 3–5 lines of notes per lab:
symptom → evidence → cause → fix → prevention. Reference fixes with explanations: [`solutions/fixes/`](solutions/fixes/).

### Lab 1 ⭐ — The crash loop
`./lab.sh break service-crash` — 502s after a "tuning" change.

### Lab 2 ⭐⭐ — Locked out
`./lab.sh break permissions` — down after a hardening job. `./lab.sh check` rejects `chmod 777`.

### Lab 3 ⭐⭐ — The full disk
`./lab.sh break disk-full` — fix the space **and** the policy.

### Lab 4 ⭐⭐ — The ghost file
`./lab.sh break deleted-file` — `df` and `du` disagree.

### Lab 5 ⭐⭐ — Full, but empty
`./lab.sh break inodes` — "No space left on device" with free space.

### Lab 6 ⭐⭐ — It keeps coming back
`./lab.sh break cpu-hog` — kill it, and it returns.

### Lab 7 ⭐⭐⭐ — Your triage script
Write `first60.sh`: every check from Lesson 1.2 into one timestamped report, read-only, skipping missing tools. Run it
on the lab server during any scenario (`docker compose cp first60.sh server:/usr/local/bin/` from `lab/`, then `sudo first60.sh`) and see if the report
alone points at the cause.

---

## ✅ Checkpoint
- [ ] I follow a method and can explain each step out loud
- [ ] I can run and read the first-60-seconds checks
- [ ] I can debug a failing systemd service, including overrides and crash loops
- [ ] I can find CPU, memory, disk, inode and deleted-file problems — and their causes
- [ ] I fix permissions with least privilege
- [ ] All six Linux scenarios pass `./lab.sh check`

👉 Next: [Module 02 — Networking Troubleshooting](../02-networking-troubleshooting/README.md)
