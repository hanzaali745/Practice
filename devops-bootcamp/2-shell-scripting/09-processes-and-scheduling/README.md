# Shell Module 09 — Processes, Signals & Scheduling 🔴

## 🎯 Objectives
- Inspect processes with `ps`, `pgrep`, `top`, `/proc`
- Run jobs in the background, `wait` for them, and run tasks **in parallel**
- Send and handle **signals** (`kill`, `SIGTERM` vs `SIGKILL`)
- Keep processes alive after logout (`nohup`, `tmux`)
- Schedule jobs with **cron** and **systemd timers**
- Manage services with `systemctl` and read logs with `journalctl`

## 🧠 Why DevOps engineers care
Servers are just processes. You'll kill stuck jobs, speed up fleet operations by running
in parallel, schedule backups and cleanups, and turn scripts into proper services. Graceful
shutdown (handling `SIGTERM`) is exactly how Docker and Kubernetes stop your containers.

---

## 📖 Lesson 9.1 — Looking at processes

```bash
ps aux                          # all processes (user, PID, %CPU, %MEM, command)
ps aux --sort=-%mem | head -5   # top memory users
ps -ef --forest                 # parent/child tree
pgrep -a nginx                  # PIDs + command lines matching "nginx"
pidof sshd
top                             # live view (press M = sort by mem, P = cpu, q = quit)
cat /proc/<PID>/status          # details from the kernel
lsof -i :8080                   # which process is using port 8080?
ss -tlnp                        # listening TCP ports + processes
```

## 📖 Lesson 9.2 — Background jobs

```bash
sleep 60 &                      # & = run in background
echo "PID of last background job: $!"
jobs                            # list this shell's jobs
fg %1                           # bring job 1 to foreground
# Ctrl+Z                        # pause the foreground job
bg %1                           # resume it in the background
wait                            # wait for ALL background jobs
wait "$pid"                     # wait for one; returns its exit code
```

## 📖 Lesson 9.3 — Parallel execution (huge time saver)

Sequential: 10 servers × 5 s = 50 s. Parallel: ~5 s.

```sh
check() { sleep 1; echo "$1 OK"; }

pids=""
for host in web-01 web-02 web-03 db-01; do
    check "$host" &              # start in the background
    pids="$pids $!"              # remember its PID ($! = PID of the last background job)
done

failed=0
for pid in $pids; do             # unquoted on purpose: split the list on spaces
    wait "$pid" || failed=$((failed + 1))   # wait returns that job's exit code
done
echo "failed: $failed"
```

All 4 checks run at the same time, so this takes ~1 second instead of 4.

Limit how many run at once with `xargs -P`:
```sh
seq -w 1 9 | sed 's/^/web-0/' | xargs -P 4 -I{} sh -c 'sleep 1; echo "{} done"'
```

## 📖 Lesson 9.4 — Signals

| Signal | Number | Meaning | Can be caught? |
|--------|--------|---------|----------------|
| `SIGHUP` | 1 | terminal closed / "reload config" | ✅ |
| `SIGINT` | 2 | Ctrl+C | ✅ |
| `SIGKILL` | 9 | kill immediately | ❌ never |
| `SIGTERM` | 15 | please stop (default `kill`) | ✅ |

```bash
kill 1234            # SIGTERM — polite: let it clean up
kill -HUP 1234       # many daemons reload config (nginx, sshd)
kill -9 1234         # SIGKILL — last resort, no cleanup!
pkill -f "python app.py"
killall nginx
```

> 🧠 Always try `SIGTERM` first, wait a few seconds, then `SIGKILL` only if needed.

Graceful shutdown in your own script:
```sh
running=true
trap 'echo "SIGTERM received, finishing current task..."; running=false' TERM
while [ "$running" = true ]; do
    echo "working..."
    sleep 1 & wait $! || true     # signals interrupt `wait` right away (plain `sleep` delays them)
done
echo "clean exit"
```

> ⚠️ A signal interrupts `wait` with an exit status above 128. Under `set -e` that would
> kill the script, so add `|| true` (see [`solutions/worker.sh`](solutions/worker.sh)).

## 📖 Lesson 9.5 — Surviving logout

```bash
nohup ./long_job.sh > job.log 2>&1 &     # ignore SIGHUP when you log out
disown                                    # detach a running job from the shell

tmux new -s deploy       # persistent terminal session (best option!)
# Ctrl+B then D          # detach; reconnect later with:
tmux attach -t deploy
```

## 📖 Lesson 9.6 — cron

```bash
crontab -e      # edit YOUR cron jobs
crontab -l      # list them
```

Format:
```
┌───────── minute (0-59)
│ ┌─────── hour (0-23)
│ │ ┌───── day of month (1-31)
│ │ │ ┌─── month (1-12)
│ │ │ │ ┌─ day of week (0-7, 0 and 7 = Sunday)
│ │ │ │ │
* * * * *  command
```

| Schedule | Meaning |
|----------|---------|
| `*/5 * * * *` | every 5 minutes |
| `0 * * * *` | every hour, on the hour |
| `30 2 * * *` | 02:30 every day |
| `0 3 * * 0` | 03:00 every Sunday |
| `0 9-17 * * 1-5` | hourly 9–17, Mon–Fri |
| `@reboot` | at startup |

Real entries:
```cron
# Always: full paths, log output, and a lock for long jobs
SHELL=/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=""

*/5 * * * * /opt/scripts/healthcheck.sh >> /var/log/healthcheck.log 2>&1
30 2 * * *  flock -n /tmp/backup.lock /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
0 4 * * 0   find /var/log/myapp -name "*.log" -mtime +14 -delete
```

> ⚠️ cron runs with a **minimal environment**: a tiny `PATH`, no `~/.bashrc` or `~/.profile`, different
> working dir. Use absolute paths, and test with `env -i sh -c '/opt/scripts/x.sh'`.
> Use https://crontab.guru to check schedules.

## 📖 Lesson 9.7 — systemd services & timers (modern Linux)

Turn a script into a managed **service** — `/etc/systemd/system/healthmon.service`:
```ini
[Unit]
Description=Health monitor
After=network-online.target

[Service]
Type=simple
ExecStart=/opt/scripts/monitor.sh
Restart=on-failure
RestartSec=5
User=monitor

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload             # after editing unit files
sudo systemctl enable --now healthmon    # start now + at boot
systemctl status healthmon
sudo systemctl restart healthmon
journalctl -u healthmon -f               # follow its logs
journalctl -u healthmon --since "1 hour ago"
```

A **timer** = cron replacement with logging, dependencies and catch-up after downtime —
see [`solutions/backup.service`](solutions/backup.service) + [`solutions/backup.timer`](solutions/backup.timer):
```bash
sudo systemctl enable --now backup.timer
systemctl list-timers
```

---

## ⚠️ Common mistakes
- `kill -9` first → no cleanup, corrupt files, stale locks
- cron jobs that work by hand but fail in cron (PATH / env / relative paths)
- No output redirection in cron → errors vanish
- Launching unlimited background jobs → overload the box. Limit with `xargs -P`

---

## 🧪 Labs

### Lab 1 ⭐ — Process detective
Find: the top 5 CPU and memory processes, the PID of your shell (`$$`), its parent (`$PPID`),
and which process listens on port 22 (`ss -tlnp`).

### Lab 2 ⭐⭐ — Parallel checker
`parallel_check.sh` checks a list of hosts **in parallel** (simulate work with `sleep`
and random failures — POSIX sh has no `$RANDOM`, read a random byte: `$(od -An -N1 -tu1 /dev/urandom)`), collects each exit code with `wait`, prints a summary and total time
(`start=$(date +%s)` … `$(( $(date +%s) - start ))`). Compare with a sequential run.

### Lab 3 ⭐⭐ — Graceful worker
`worker.sh` loops forever doing "work", writes its PID to a file, handles `SIGTERM`/`SIGINT` by
finishing the current iteration and removing the PID file, and reloads a config file on `SIGHUP`.
Test with `kill -TERM`, `kill -HUP`.

### Lab 4 ⭐⭐ — Cron it
Schedule `monitor.sh` (from solutions) every minute with cron, logging to a file. Verify
with `tail -f`. Then remove the cron entry.

### Lab 5 ⭐⭐⭐ — systemd timer (needs a systemd machine/VM)
Install `backup.service` + `backup.timer` from solutions, run daily at 02:30 with
`Persistent=true`. Check `systemctl list-timers` and `journalctl -u backup`.

---

## ✅ Checkpoint
- [ ] I use `SIGTERM` before `SIGKILL` and handle `TERM` in long-running scripts
- [ ] I can run tasks in parallel and collect their exit codes
- [ ] I can write a cron line and a systemd service/timer

👉 Next: [Module 10 — Shell Capstone](../10-capstone/README.md)
