# Module 01 — Linux Terminal Essentials 🟢

## 🎯 Objectives
- Navigate the filesystem confidently
- Create, copy, move, delete, and view files
- Understand permissions and ownership
- Get help with `man` and `--help`
- Know the key Linux directories

## 🧠 Why DevOps engineers care
Shell scripts are just **terminal commands saved in a file**. If you can't drive the terminal,
you can't script it. On servers there's no GUI — the terminal is all you get.

---

## 📖 Lesson 1.1 — Where am I? Moving around

```bash
pwd                 # print working directory
ls                  # list files
ls -l               # long format (permissions, owner, size, date)
ls -la              # include hidden files (start with .)
ls -lh              # human-readable sizes
ls -lt              # sort by time, newest first

cd /var/log         # absolute path (starts with /)
cd ..               # up one level
cd -                # back to previous dir
cd ~                # home  (or just: cd)
cd ../../etc        # relative path
```

## 📖 Lesson 1.2 — The Linux filesystem map

| Path | What lives there |
|------|------------------|
| `/` | root of everything |
| `/home/<user>` | users' home dirs (`~`) |
| `/root` | root user's home |
| `/etc` | **configuration files** (nginx, ssh, hosts) |
| `/var/log` | **logs** |
| `/var/lib` | app data (docker, mysql) |
| `/tmp` | temporary files (cleared on reboot) |
| `/usr/bin`, `/bin` | programs |
| `/usr/local/bin` | your own installed tools/scripts |
| `/opt` | third-party apps |
| `/proc` | live kernel/process info (`/proc/cpuinfo`, `/proc/meminfo`) |
| `/dev` | devices (disks: `/dev/sda`) |

## 📖 Lesson 1.3 — Files & directories

```bash
mkdir projects
mkdir -p app/{config,logs,scripts}    # nested + brace expansion → 3 dirs
touch app/config/app.conf             # create empty file / update timestamp

cp app.conf app.conf.bak              # copy file
cp -r app app-backup                  # copy directory (recursive)
mv old.txt new.txt                    # rename
mv file.txt /tmp/                     # move
rm file.txt                           # delete (NO recycle bin!)
rm -r app-backup                      # delete directory
rm -ri something                      # ask before each delete (safe)
rmdir emptydir

ln -s /opt/app/current /usr/local/app # symbolic link (shortcut)
```

> ⚠️ `rm -rf` is permanent. Double-check paths. Never run `rm -rf /` or `rm -rf $VAR/` without checking `$VAR` is set!

## 📖 Lesson 1.4 — Viewing files

```bash
cat file.txt          # print whole file
less /var/log/syslog  # scroll (q to quit, / to search, G end, g start)
head -n 20 file       # first 20 lines
tail -n 20 file       # last 20 lines
tail -f app.log       # FOLLOW a log live (Ctrl+C to stop) ← you'll use this daily
wc -l file            # count lines
file mystery.bin      # what type is it?
```

## 📖 Lesson 1.5 — Finding things

```bash
find /var/log -name "*.log"               # by name
find . -type f -size +100M                # files bigger than 100MB
find /tmp -type f -mtime +7               # modified more than 7 days ago
grep "ERROR" app.log                      # search inside files (Module 08 deep dive)
grep -r "listen" /etc/nginx/              # recursive
which python3                             # where is a command?
```

## 📖 Lesson 1.6 — Permissions

```
-rwxr-xr--  1 alice devops  1024 May 1 10:00 deploy.sh
│└┬┘└┬┘└┬┘     │     │
│ │  │  └ others: r-- (read)
│ │  └─── group:  r-x (read, execute)
│ └────── owner:  rwx (read, write, execute)
└──────── type: - file, d directory, l link
```

| Letter | Number | On a file | On a directory |
|--------|--------|-----------|----------------|
| `r` | 4 | read | list |
| `w` | 2 | modify | create/delete inside |
| `x` | 1 | execute | enter (`cd`) |

```bash
chmod +x deploy.sh          # add execute for everyone
chmod u+x,g-w file          # symbolic
chmod 755 deploy.sh         # rwxr-xr-x  (7=4+2+1, 5=4+1)
chmod 644 app.conf          # rw-r--r--  (typical config)
chmod 600 ~/.ssh/id_rsa     # rw-------  (private keys MUST be 600)
sudo chown alice:devops file   # change owner:group
sudo chown -R www-data /var/www
```

## 📖 Lesson 1.7 — Users & sudo

```bash
whoami              # current user
id                  # uid, gid, groups
sudo command        # run as root
sudo -i             # root shell (use sparingly!)
su - alice          # switch user
```

## 📖 Lesson 1.8 — Getting help

```bash
man ls              # full manual (q to quit)
ls --help           # quick help
type cd             # builtin, alias, or program?
history             # previous commands; !42 reruns #42; Ctrl+R searches
```

**Keyboard shortcuts:** `Tab` autocomplete · `Ctrl+C` cancel · `Ctrl+L` clear ·
`Ctrl+A`/`Ctrl+E` start/end of line · `Ctrl+R` search history · `↑` previous command.

## 📖 Lesson 1.9 — System info quick commands

```bash
uname -a        # kernel
cat /etc/os-release
uptime          # load average
df -h           # disk space
du -sh /var/log # size of a directory
free -h         # memory
top / htop      # live processes (q to quit)
ip a            # network interfaces / IPs
```

---

## 🧪 Labs

### Lab 1 ⭐ — Project skeleton
In one `mkdir -p` command with brace expansion, create:
```
myapp/
├── bin/
├── config/{dev,prod}/
├── logs/
└── scripts/
```
Then create `config/dev/app.conf` and `config/prod/app.conf` with `touch`.
Verify with `find myapp`.

### Lab 2 ⭐ — Permission practice
1. Create `deploy.sh`, make it `rwxr-x---` using numbers.
2. Create `secret.key` readable/writable **only** by you.
3. Run `ls -l` and explain each permission string out loud.

### Lab 3 ⭐⭐ — Log explorer
1. List the 5 largest files in `/var/log` (hint: `ls -lS | head`, or `du -ah /var/log | sort -h | tail`)
2. Show the last 10 lines of a system log (`/var/log/syslog` or `journalctl -n 10`)
3. Find all `.conf` files in `/etc` (2 levels deep max: `-maxdepth 2`)

### Lab 4 ⭐⭐ — System report (by hand)
Using only commands from this module, find and write down: your OS name & version,
kernel version, uptime, disk usage of `/`, total memory, your IP address, your user id.
In Module 02 you'll turn this into a script!

---

## ✅ Checkpoint
- [ ] I can navigate with absolute and relative paths
- [ ] I can read `-rwxr-x---` and use `chmod 755`/`644`/`600`
- [ ] I use `tail -f`, `less`, `find`, and `man`

👉 Next: [Module 02 — Your First Script](../02-first-script/README.md)
