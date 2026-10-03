# Linux Module 05 — Services, Boot & Time 🟡

## 🎯 Objectives
- Explain how Linux boots: firmware → bootloader → kernel → initramfs → systemd → targets
- Manage services with `systemctl` and read their logs with `journalctl`
- **Write your own systemd service** — running as an unprivileged user, restarting on failure, hardened
- Schedule jobs with **systemd timers** (and know when cron is still fine)
- Configure journald retention, the time zone and time sync, and the host name

## 🧠 Why DevOps engineers care
Every daemon you'll run on a VM — nginx, a database, the Prometheus node exporter, the Docker engine, your own app —
is a systemd unit. Kubernetes nodes run the kubelet as one. Shell Module 09 taught processes and cron; this module
makes you the person who can package any program as a reliable, secure service.

---

## 📖 Lesson 5.1 — How Linux boots

1. **Firmware** (UEFI/BIOS) finds a boot disk.
2. **Bootloader** (GRUB) loads the **kernel** and the **initramfs** (a mini root file system with drivers).
3. The kernel starts **PID 1 = systemd**, which mounts file systems (`/etc/fstab`) and starts units in dependency order
   until it reaches the default **target** (`multi-user.target` on servers, `graphical.target` on desktops).

```bash
systemctl get-default                 # which target we boot into
systemd-analyze; systemd-analyze blame | head   # how long boot took, and who was slow
journalctl -b -1 -p err               # errors from the PREVIOUS boot (why did it crash/reboot?)
journalctl --list-boots
```
Kernel command-line options live in `/etc/default/grub` (`GRUB_CMDLINE_LINUX`), then `sudo update-grub`. In the cloud,
the provider's serial console is how you see a server that won't boot.

## 📖 Lesson 5.2 — systemctl

```bash
systemctl status nginx                # state, main PID, memory, last log lines
sudo systemctl start|stop|restart|reload nginx
sudo systemctl enable --now nginx     # start now AND at boot (enable = create the WantedBy= link)
systemctl is-active nginx; systemctl is-enabled nginx; systemctl is-failed nginx
systemctl list-units --type=service --state=running
systemctl --failed
systemctl cat nginx                   # unit file + drop-ins
sudo systemctl edit nginx             # create a drop-in override (never edit files in /usr/lib/systemd)
sudo systemctl daemon-reload          # after creating/changing unit files yourself
sudo systemctl mask cups              # make it impossible to start
```
Unit files: vendor ones in `/usr/lib/systemd/system/`, yours in `/etc/systemd/system/` (which wins).

## 📖 Lesson 5.3 — Writing a service

```ini
[Unit]
Description=My app
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/my-app --port 8080
User=myapp                      # or DynamicUser=yes: a throw-away user, created by systemd
Restart=on-failure
RestartSec=5
Environment=LOG_LEVEL=info      # or EnvironmentFile=/etc/my-app.env (secrets: mode 600)
# hardening — check what's left with: systemd-analyze security my-app
NoNewPrivileges=yes
ProtectSystem=strict            # the OS is read-only for this service...
ReadWritePaths=/var/lib/my-app  # ...except what it needs
ProtectHome=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```
Types: `simple` (default: the process **is** the service), `oneshot` (runs and exits — jobs), `notify`, `forking`
(old daemons). Write logs to **stdout**: systemd sends them to the journal.

## 📖 Lesson 5.4 — Timers (systemd's cron)

A timer starts a service on a schedule:
```ini
# backup.timer                         # backup.service (Type=oneshot) does the work
[Timer]
OnCalendar=*-*-* 02:00:00              # daily at 02:00 (also: hourly, Mon..Fri 09:00, *:0/15)
Persistent=true                        # missed while the machine was off? run at next boot
RandomizedDelaySec=5min                # don't hit the backup server at the same second as 500 other machines
[Install]
WantedBy=timers.target
```
```bash
systemd-analyze calendar 'Mon..Fri 09:00'     # check an expression
systemctl list-timers                          # next and last run of every timer
sudo systemctl start backup.service            # run the job NOW to test it
```
Timers beat cron for logging (journal), dependencies, resource limits and missed runs. Cron (`/etc/cron.d/`) is still
everywhere — read both.

## 📖 Lesson 5.5 — The journal

```bash
journalctl -u nginx --since "1 hour ago" -p warning
journalctl -f                        # follow everything
journalctl -o json-pretty -n 1       # structured fields
journalctl --disk-usage
sudo journalctl --vacuum-size=200M   # shrink now
```
Make it permanent with a drop-in: `/etc/systemd/journald.conf.d/size.conf` → `[Journal]` `SystemMaxUse=200M`, then
`sudo systemctl restart systemd-journald`. The journal is persistent when `/var/log/journal/` exists (Ubuntu default).

## 📖 Lesson 5.6 — Time, time zones and host names

```bash
timedatectl                          # time zone, NTP sync status
sudo timedatectl set-timezone UTC    # servers: UTC, so logs from everywhere line up
timedatectl timesync-status          # systemd-timesyncd (or chrony: chronyc tracking)
hostnamectl; sudo hostnamectl set-hostname web-01
```
Clock drift breaks TLS, Kerberos, distributed databases and log correlation — always run time sync. After changing the
host name, update `/etc/hosts` (`127.0.1.1 web-01`).

---

## ⚠️ Common mistakes
- Editing unit files and forgetting `daemon-reload`; editing vendor files in `/usr/lib/systemd`
- `enable` without `--now` (or the other way round) and being surprised after a reboot
- Services running as root because nobody set `User=`/`DynamicUser=`
- `Restart=always` hiding a crash loop — check `systemctl status` and the journal
- Servers in local time zones; no time sync; journals without a size limit

---

## 🧪 Labs
On your lab VM. Reference solution: [`solutions/labs.sh`](solutions/labs.sh). Check: `sudo lab/check.sh 05`.

### Lab 1 ⭐⭐ — Your own service
Write `/usr/local/bin/lab-heartbeat` (prints `heartbeat <time>` every 10 s) and `lab-heartbeat.service`: never runs
as root, restarts on failure, hardened. Enable and start it; watch it with `journalctl -u lab-heartbeat -f`. Kill its
process with `kill -9` and watch systemd bring it back. Run `systemd-analyze security lab-heartbeat`.

### Lab 2 ⭐⭐ — A daily job
`lab-report.timer` + `lab-report.service` (oneshot): every day at 02:00, write the date, uptime and disk usage to
`/var/lib/lab-report/report.txt`. Run the service once by hand to test it; check `systemctl list-timers`.

### Lab 3 ⭐ — Journal and time
Cap the journal at 200M with a drop-in. Set the time zone to UTC. Check time sync is active.

### Lab 4 ⭐⭐ — Boot detective
Reboot the VM (`sudo reboot`). Afterwards: how long did boot take and what was slowest? Are your services back? Find
the previous boot's log with `journalctl -b -1`.

---

## ✅ Checkpoint
- [ ] I can explain the boot process and find errors from the previous boot
- [ ] I can manage services and read their logs
- [ ] I can write a hardened service that runs as a non-root user and restarts on failure
- [ ] I can schedule a job with a systemd timer
- [ ] My servers use UTC, sync time, and cap the journal
- [ ] `sudo lab/check.sh 05` passes

👉 Next: [Module 06 — Storage: Disks, File Systems & LVM](../06-storage/README.md)
