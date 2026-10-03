# 🐧 Phase 2B: Linux Administration

> **Before you start:** finish Phase 2 (Shell scripting) — it taught you the terminal, files, pipes, processes and
> cron. This phase turns that into **running Linux servers**: users, permissions, packages, services, disks, the kernel,
> networking and security. Phase 3 (Bash) comes right after.
> **Practise on a throw-away VM**, never your own machine — the labs change users, disks and the firewall:
> `lab/new-vm.sh` creates one with [Multipass](https://multipass.run) in two minutes, and `lab/check.sh` tells you when
> each module's labs are done.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [The Filesystem & Files](01-filesystem-and-files/README.md) | 🟢 | the FHS, inodes and links, find, tar backups, man |
| 02 | [Users, Groups & sudo](02-users-groups-sudo/README.md) | 🟢 | passwd/shadow/group, users and groups, service accounts, offboarding, sudoers.d |
| 03 | [Permissions in Depth](03-permissions-in-depth/README.md) | 🟡 | umask, setuid/setgid/sticky, ACLs, chattr, capabilities |
| 04 | [Packages & Software](04-packages/README.md) | 🟡 | apt and dpkg, repositories and keys, holds, your own .deb, auto-updates |
| 05 | [Services, Boot & Time](05-services-boot-time/README.md) | 🟡 | the boot process, systemctl, writing services and timers, journald, time |
| 06 | [Storage: Disks, File Systems & LVM](06-storage/README.md) | 🔴 | partitions, mkfs, fstab, swap, LVM, growing volumes online |
| 07 | [Processes, Resources & the Kernel](07-processes-and-kernel/README.md) | 🔴 | /proc, priorities, limits, cgroups, sysctl, kernel modules |
| 08 | [Networking & Server Hardening](08-networking-and-hardening/README.md) | 🔴 | ip and netplan, ss, ufw, SSH hardening, a new-server baseline |
| 09 | [Capstone: Build a Server](09-capstone/README.md) | 🏆 | one idempotent script from fresh VM to finished server |

## Your lab

```bash
sudo snap install multipass                       # once (macOS/Windows: https://multipass.run)
cd ~/Practice/devops-bootcamp/2b-linux-admin/lab
./new-vm.sh                                       # Ubuntu 24.04 VM "linuxlab", with ~/Practice mounted inside
multipass shell linuxlab
cd ~/Practice/devops-bootcamp/2b-linux-admin
sudo lab/check.sh 02                              # after a module's labs: ✅ or what's missing
sudo lab/cleanup.sh                               # undo every lab change — or: ./new-vm.sh --delete && ./new-vm.sh
```
| File | What |
|------|------|
| [`lab/new-vm.sh`](lab/new-vm.sh) | create / delete the throw-away VM |
| [`lab/check.sh`](lab/check.sh) | checks each module's lab results (read-only); `all` = the capstone's definition of done |
| [`lab/cleanup.sh`](lab/cleanup.sh) | removes every lab user, file, unit, disk image and rule |
| `lab/test/` | maintainers only: proves every solution passes its checks, in a container |

## Cheat sheet

```bash
cat /etc/os-release; uname -r; hostnamectl; lsblk -f; findmnt; df -hT; free -h
id alice; getent passwd alice; sudo useradd -m -s /bin/bash alice; sudo usermod -aG grp alice; sudo chage -l alice
sudo visudo -f /etc/sudoers.d/x; sudo -l -U bob; namei -l /path; getfacl dir; setfacl -d -m g:grp:rwx dir; chattr +i f
apt-cache policy pkg; dpkg -L pkg; dpkg -S /path; sudo apt-mark hold pkg; dpkg-deb --build dir
systemctl status|cat|edit unit; systemctl list-timers; journalctl -u unit -b -p err; systemd-analyze blame
parted -s DISK mklabel gpt mkpart p ext4 1MiB 100%; mkfs.ext4; blkid; findmnt --verify; mount -a
pvcreate; vgcreate vg DISKS; lvcreate -L 1G -n lv vg; lvextend -r -L +1G vg/lv; swapon --show
cat /proc/PID/limits; systemd-cgtop; sysctl -w k=v; /etc/sysctl.d/; modprobe; dmesg -T
ip -br a; ip r; resolvectl status; ss -tlnp; ufw allow OpenSSH && ufw enable; sshd -t; sshd -T
```

## 🏅 Linux expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain the Filesystem Hierarchy, inodes and links, and back up and restore with tar
- [ ] Manage users, groups, service accounts and offboarding; write least-privilege sudo rules safely
- [ ] Design permissions for a team folder with setgid and ACLs; explain setuid, sticky and chattr
- [ ] Install, inspect, hold and package software with apt/dpkg; add a signed third-party repository
- [ ] Write a hardened systemd service and a timer; read the journal; explain the boot process
- [ ] Partition, format and mount disks with a safe fstab; add swap; build and grow LVM volumes online
- [ ] Inspect processes via /proc; set limits, priorities and cgroup limits; tune and persist sysctls
- [ ] Configure networking and a firewall, harden SSH, and apply a new-server baseline without locking yourself out
- [ ] Build a server from scratch with one idempotent script

👉 Start: [Module 01 — The Filesystem & Files](01-filesystem-and-files/README.md)
