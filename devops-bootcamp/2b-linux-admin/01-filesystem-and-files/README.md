# Linux Module 01 — The Filesystem & Files 🟢

## 🎯 Objectives
- Know what Linux is made of: kernel, distribution, userland — and how to find out what you're running
- Find your way around the Filesystem Hierarchy: what lives in `/etc`, `/var`, `/usr`, `/opt`, `/proc`, `/dev`...
- Understand inodes, hard links and symbolic links
- Find anything with `find`, `locate`, `which` and `type`
- Back up and restore with `tar`, keeping owners and permissions
- Use `man` like a pro

## 🧠 Why DevOps engineers care
Every config file, log, service, container layer and Kubernetes node is a Linux filesystem underneath. "Where is the
config?", "where do the logs go?", "why is this file still taking space?" — these questions come up daily, and the
answers all follow the same map. Shell Module 01 taught you to move around; this module teaches you the territory.

---

## 🧪 Your lab VM (all of Phase 2B)
The labs in this phase change users, disks, services and the firewall — do them on a **throw-away VM**, never your
own laptop or a server you care about.

```bash
sudo snap install multipass                                   # macOS/Windows: https://multipass.run
cd ~/Practice/devops-bootcamp/2b-linux-admin/lab
./new-vm.sh                                                   # Ubuntu 24.04 VM "linuxlab", course mounted inside
multipass shell linuxlab                                      # you are now "ubuntu" on the VM, with sudo
cd ~/Practice/devops-bootcamp/2b-linux-admin
sudo lab/check.sh 01                                          # after the labs: did it work?
```
Broke it? `./new-vm.sh --delete && ./new-vm.sh` gives you a fresh one in two minutes, or `sudo lab/cleanup.sh` removes
everything the labs created. (On WSL: do this phase in a Multipass VM too — WSL lacks parts of a real server.)

---

## 📖 Lesson 1.1 — What am I running?

```bash
uname -r                  # kernel version (6.8.0-...)  — the kernel is "Linux"
cat /etc/os-release       # the distribution: Ubuntu 24.04 — kernel + userland (GNU tools, systemd, apt...)
hostnamectl               # host name, OS, kernel, architecture, VM or not
lscpu; free -h; lsblk     # CPUs, memory, disks
```
**Distributions** differ mainly in package manager and release model: Debian/Ubuntu (`apt`, `.deb`), RHEL/Rocky/
Alma/Fedora (`dnf`, `.rpm`), Alpine (`apk`, tiny — common in containers). Skills transfer; commands mostly do too.

## 📖 Lesson 1.2 — The Filesystem Hierarchy

| Path | What's there | You'll touch it when… |
|------|--------------|-----------------------|
| `/etc` | system-wide **configuration** (text files) | configuring anything: ssh, nginx, users, fstab |
| `/var` | **variable** data: `/var/log` logs, `/var/lib` app state (databases, Docker), `/var/cache`, `/var/spool` | a disk fills up, you need logs |
| `/usr` | installed software: `/usr/bin`, `/usr/lib`, `/usr/share` (read-only in spirit) | finding a binary or its docs |
| `/usr/local`, `/opt` | software **you** install by hand (not from packages) | installing a tool from a tarball |
| `/home`, `/root` | users' homes, root's home | user files, dotfiles |
| `/tmp` | temporary files (often cleared at boot) | never for anything you want to keep |
| `/boot` | kernel and bootloader files | kernel upgrades, boot problems |
| `/dev` | **devices** as files: disks `/dev/sda`, `/dev/null`, `/dev/random` | disks and partitions |
| `/proc`, `/sys` | **virtual**: the kernel's live view of processes and hardware | tuning, debugging |
| `/run` | runtime state since boot (PID files, sockets) | — |

"Everything is a file": `ls -l` shows the type in the first character — `-` file, `d` directory, `l` symlink,
`c`/`b` character/block device, `s` socket, `p` pipe. `file X` tells you what's inside a file.

## 📖 Lesson 1.3 — Inodes and links

A file's **name** lives in a directory; its **data and metadata** (owner, mode, size, blocks) live in an **inode**.
```bash
ls -li file              # the first column is the inode number
stat file                # everything the inode knows
ln original hard         # a HARD link: another name for the SAME inode (same file system only; not for directories)
ln -s original soft      # a SYMBOLIC link: a tiny file containing a path (can cross file systems, can dangle)
```
Delete `original`: the hard link still has the data (the inode lives until its last name is gone *and* no process has
it open — remember that for "deleted but still using space"). The symlink now points nowhere.

## 📖 Lesson 1.4 — Finding things

```bash
find /var/log -name '*.log' -mtime -1               # changed in the last day
find / -xdev -type f -size +100M 2>/dev/null        # big files on THIS file system only (-xdev)
find /srv -user alice -perm -o=w                    # owned by alice AND writable by others
find /tmp -type f -mtime +7 -delete                 # clean up (try without -delete first!)
find . -name '*.conf' -exec grep -l 'listen' {} +   # run a command on the results
locate nginx.conf                                   # instant, from a database (sudo updatedb to refresh)
which python3; type ls                              # where a command comes from (alias? builtin? file?)
```

## 📖 Lesson 1.5 — Archives and backups

```bash
tar -czpf /var/backups/etc.tar.gz -C / etc          # c=create z=gzip p=keep permissions f=file; -C / → paths "etc/..."
tar -tvzf /var/backups/etc.tar.gz | head            # list (t) with details (v)
tar -xzpf /var/backups/etc.tar.gz -C /tmp/restore etc/ssh/sshd_config   # extract ONE file, elsewhere
```
`zstd` (`tar --zstd`) is faster than gzip. Restore into a temporary folder and compare — never straight over a live
`/etc`. A backup you've never restored is a hope, not a backup.

## 📖 Lesson 1.6 — Reading the manual

`man 5 crontab` (section 5 = file formats) vs `man 1 crontab` (the command). Sections: 1 commands, 5 file formats,
8 admin commands. Inside `man`: `/word` search, `n` next, `q` quit. `man -k keyword` searches all pages. `cmd --help`
for a quick summary; `tldr cmd` (installable) for examples.

---

## ⚠️ Common mistakes
- Editing files in `/usr` that a package will overwrite on upgrade — configuration belongs in `/etc`
- Putting important data in `/tmp`
- `find /` without `-xdev` crawling `/proc` and network mounts; `-delete` before checking what matches
- Absolute paths in tar archives, then extracting over the live system
- Thinking a symlink is a copy

---

## 🧪 Labs
On your lab VM. Reference solution: [`solutions/labs.sh`](solutions/labs.sh). Check: `sudo lab/check.sh 01`.

### Lab 1 ⭐ — Tour
Answer from the VM, with commands: kernel version, distribution and version, CPU count, total memory, disk sizes,
where nginx's config would live, where logs go, what `/proc/cpuinfo` and `/dev/null` are.

### Lab 2 ⭐ — Links
In `/srv/lab/links`: create `original.txt`, a hard link `hard.txt` and a symlink `soft.txt` → `original.txt`
(relative). Prove with `ls -li` which share an inode. Delete `original.txt` in a copy of the folder: what happens to each?

### Lab 3 ⭐⭐ — Find
Write every regular file over 1 MiB under `/usr` (this file system only) to `/srv/lab/find/big-files.txt`, sorted.
Then: files changed in `/etc` in the last 7 days; files in `/var/log` bigger than 10 MiB.

### Lab 4 ⭐⭐ — Backup and restore
Back up `/etc` to `/var/backups/lab/etc-backup.tar.gz` **keeping permissions**, with paths starting `etc/`. Restore
only `etc/hostname` into `/tmp/restore` and compare it with the original.

---

## ✅ Checkpoint
- [ ] I can say what lives in each top-level directory
- [ ] I can explain inodes, hard links and symlinks
- [ ] I can find files by name, size, age, owner and permission
- [ ] I can back up and restore with tar, keeping permissions
- [ ] `sudo lab/check.sh 01` passes

👉 Next: [Module 02 — Users, Groups & sudo](../02-users-groups-sudo/README.md)
