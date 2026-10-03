# Linux Module 07 — Processes, Resources & the Kernel 🔴

## 🎯 Objectives
- Inspect processes deeply: states, parents, threads, open files, and the `/proc` file system
- Control priority (`nice`, `renice`, `ionice`) and limits (`ulimit`, `limits.conf`, systemd `Limit*=`)
- Understand cgroups — the kernel feature behind systemd resource control and every container
- Tune the kernel with `sysctl`, persistently
- Load and inspect kernel modules; read the kernel log

## 🧠 Why DevOps engineers care
"Too many open files", a batch job starving the web server, a database asking for kernel tuning, containers being
OOM-killed at their memory limit — all of it lives here. Docker's `--memory`, Kubernetes `resources.limits` and the
kubelet's sysctls are friendly front ends for exactly these kernel features.

---

## 📖 Lesson 7.1 — Processes up close

Shell Module 09 covered `ps`, `top`, `kill`, jobs and cron. Going deeper:
```bash
ps -eo pid,ppid,user,stat,ni,%cpu,%mem,etime,cmd --sort=-%cpu | head
pstree -p | head -30                # who started whom
ps -o pid,stat,cmd -p PID           # STAT: R running, S sleeping, D waiting on IO (can't be killed!), Z zombie, T stopped
ls -l /proc/PID/fd | wc -l          # open files of a process
cat /proc/PID/status                # memory (VmRSS), threads, UID/GID
cat /proc/PID/limits                # its limits
cat /proc/loadavg; cat /proc/meminfo | head
```
Everything `ps` and `top` show comes from `/proc`. `/sys` is the same idea for devices and kernel settings.

## 📖 Lesson 7.2 — Priority

```bash
nice -n 10 tar -czf /backup/big.tgz /data      # start with lower CPU priority (nice 19 = lowest, -20 = highest)
sudo renice -n 5 -p PID                        # change a running process
ionice -c3 -p PID                              # idle IO class: only use the disk when nobody else wants it
```
Only root can raise priority (negative nice). For services use `Nice=`, `IOSchedulingClass=` and better: `CPUWeight=`,
`MemoryMax=` in the unit (cgroups, below).

## 📖 Lesson 7.3 — Limits

```bash
ulimit -a                          # this shell's limits (soft); ulimit -Hn = hard limit for open files
ulimit -n 4096                     # raise the soft limit (up to the hard limit) for this shell
```
- **People / login sessions:** `/etc/security/limits.d/*.conf` (`@devteam soft nofile 4096`), applied by PAM at login.
- **systemd services ignore limits.conf** — set it in the unit: `LimitNOFILE=65536`, `LimitNPROC=`, `TasksMax=`.
- "Too many open files" (EMFILE) = the process hit `nofile`. Check `/proc/PID/limits` and `ls /proc/PID/fd | wc -l`.

## 📖 Lesson 7.4 — cgroups

Control groups put processes in a tree and limit/measure CPU, memory, IO and process counts per group. systemd puts
every service in its own cgroup; Docker and Kubernetes put every container in one.
```bash
systemd-cgls                                   # the tree
systemd-cgtop                                  # live usage per group
systemctl show -p MemoryCurrent,CPUUsageNSec nginx
sudo systemctl set-property nginx MemoryMax=500M CPUQuota=50%   # limit a running service (persists as a drop-in)
cat /sys/fs/cgroup/system.slice/nginx.service/memory.max
```
When a cgroup hits `MemoryMax`, the OOM killer kills inside **that** group only — exactly what happens to a container
over its memory limit (`OOMKilled`).

## 📖 Lesson 7.5 — Kernel tuning with sysctl

```bash
sysctl net.core.somaxconn                      # read
sudo sysctl -w net.core.somaxconn=1024         # change now (lost at reboot)
echo 'net.core.somaxconn = 1024' | sudo tee /etc/sysctl.d/90-web.conf   # persist
sudo sysctl -p /etc/sysctl.d/90-web.conf       # apply that file (sysctl --system applies all)
```
| Parameter | Typical reason |
|-----------|----------------|
| `vm.swappiness` (10) | databases: prefer keeping memory in RAM |
| `net.core.somaxconn` | longer accept queue for busy servers |
| `net.ipv4.ip_local_port_range` | more outgoing ports for proxies/load balancers |
| `fs.file-max`, `fs.inotify.max_user_watches` | many files; file watchers (IDEs, log shippers) |
| `vm.max_map_count` (262144) | Elasticsearch (you'll set this in Phase 10) |
| `net.ipv4.ip_forward` (1) | routers, NAT, Kubernetes nodes |

Change one thing at a time, for a measured reason, and document why — copied "performance tuning" lists cause outages.

## 📖 Lesson 7.6 — Kernel modules and the kernel log

```bash
lsmod | head; modinfo overlay        # loaded modules (drivers, file systems, netfilter...)
sudo modprobe br_netfilter           # load one (Kubernetes needs overlay and br_netfilter)
echo br_netfilter | sudo tee /etc/modules-load.d/k8s.conf   # load at every boot
sudo dmesg -T | tail; journalctl -k  # kernel messages: hardware errors, OOM kills, segfaults
```

---

## ⚠️ Common mistakes
- Raising limits in `limits.conf` for a systemd service (it ignores it)
- `sysctl -w` without persisting it — the "fix" disappears at the next reboot
- Pasting tuning guides wholesale; no record of why a value was changed
- `kill -9` on a process in state `D` (it can't die until its IO finishes — find the stuck disk/NFS instead)
- Forgetting that a container's memory limit is a cgroup limit, not the host's free memory

---

## 🧪 Labs
On your lab VM, after Modules 02 and 05. Reference solution: [`solutions/labs.sh`](solutions/labs.sh).
Check: `sudo lab/check.sh 07`.

### Lab 1 ⭐ — /proc tour
For `lab-heartbeat`'s main process: parent PID, state, user, memory (RSS), number of open files, and its limits — using
only `/proc` (then compare with `ps` and `systemctl status`).

### Lab 2 ⭐⭐ — Kernel parameters
Set `net.core.somaxconn = 1024` and `net.ipv4.ip_local_port_range = 10240 65000` in `/etc/sysctl.d/90-lab.conf`, apply
them, and prove they survive a reboot.

### Lab 3 ⭐⭐ — Limits two ways
Give `lab-heartbeat` `LimitNOFILE=65536` with a drop-in (prove it in `/proc/PID/limits`). Give members of `devteam`
4096 soft / 8192 hard open files at login via `/etc/security/limits.d/90-lab.conf` (prove it as alice).

### Lab 4 ⭐⭐ — Priorities and cgroups
Start a CPU hog (`yes > /dev/null &`) twice, one with `nice -n 19`; compare their CPU share in `top`. Then limit
`lab-heartbeat` to `CPUQuota=5%` with `systemctl set-property` and find the setting in `/sys/fs/cgroup`. Kill the hogs.

---

## ✅ Checkpoint
- [ ] I can inspect any process through `/proc` and read its state, files and limits
- [ ] I know where limits come from for login users vs systemd services
- [ ] I can explain cgroups and limit a service's CPU and memory
- [ ] I can tune and persist kernel parameters — and explain why
- [ ] `sudo lab/check.sh 07` passes

👉 Next: [Module 08 — Networking & Hardening](../08-networking-and-hardening/README.md)
