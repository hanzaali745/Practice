# Bash Module 05 — Remote Servers: SSH, scp & rsync 🔴

## 🎯 Objectives
- Log in to servers with **SSH keys** (no passwords)
- Use `~/.ssh/config` so `ssh web-01` just works
- Run commands and whole scripts **remotely**
- Copy files with `scp` and sync folders with `rsync`
- Run a command across a **fleet** of servers — one by one and in parallel
- Know the SSH security basics every DevOps engineer must follow

## 🧠 Why DevOps engineers care
Your servers live in a data centre or the cloud — you reach **all** of them through SSH.
Deploy scripts, backups, log collection, Ansible: it's all SSH under the hood. This module turns
"I can log in to one server" into "I can operate 50 servers from one script".

---

## 🧪 Your practice server: `localhost`

You don't need 50 servers to learn — your own Ubuntu machine can be the "remote" server:

```bash
sudo apt install -y openssh-server rsync     # the SSH server + rsync
sudo systemctl enable --now ssh              # start it (WSL: sudo service ssh start)
ssh localhost                                # test: answer "yes", type your password, then `exit`
```

Everything below works the same against a real cloud VM — just replace `localhost` with its IP.
(Free option: an AWS/GCP/Azure free-tier Ubuntu VM, or `multipass launch --name web-01`.)

---

## 📖 Lesson 5.1 — SSH basics

```bash
ssh user@host                    # log in (user defaults to your local username)
ssh -p 2222 user@host            # non-standard port
ssh user@host 'uptime'           # run ONE command remotely and come back
ssh user@host 'df -h / && free -h'
exit                             # leave the remote shell (or Ctrl+D)
```

The first time you connect, SSH shows the server's **fingerprint** and saves it to
`~/.ssh/known_hosts`. If it ever changes unexpectedly (`WARNING: REMOTE HOST IDENTIFICATION HAS
CHANGED`), **stop** — the server was rebuilt, or someone is intercepting your connection.

## 📖 Lesson 5.2 — SSH keys (do this once)

Passwords are slow, can be guessed, and can't be used by scripts. Keys fix all three.

```bash
ssh-keygen -t ed25519 -C "you@laptop"        # create a key pair (press Enter for defaults;
                                             # set a passphrase for real use)
ls ~/.ssh/
# id_ed25519      ← PRIVATE key: never share, never commit, permissions 600
# id_ed25519.pub  ← PUBLIC key: safe to give to servers

ssh-copy-id localhost                        # put your public key on the server
ssh localhost 'echo logged in with a key!'   # no password prompt now 🎉
```

`ssh-copy-id` appends your public key to `~/.ssh/authorized_keys` on the server. Cloud providers
do the same thing when you choose a "key pair" while creating a VM.

Permissions SSH insists on (it refuses keys that are too open):
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/id_ed25519.pub
```

**ssh-agent** keeps a passphrase-protected key unlocked for your session:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## 📖 Lesson 5.3 — `~/.ssh/config`: nicknames for servers

```text
# ~/.ssh/config
Host web-01
    HostName 203.0.113.10
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519

Host web-*                         # settings for every host matching the pattern
    User deploy
    Port 22

Host bastion
    HostName 198.51.100.5
    User admin

Host private-db
    HostName 10.0.2.15
    ProxyJump bastion              # hop through the bastion to reach a private server

Host *                             # defaults for everything
    ServerAliveInterval 30
    ConnectTimeout 10
```

Now `ssh web-01`, `scp file web-01:/tmp/` and `rsync ... private-db:` all use these settings.
For practice, add an alias for your own machine:

```text
Host lab
    HostName localhost
```

## 📖 Lesson 5.4 — Running commands & scripts remotely (the important details)

```bash
ssh lab 'hostname; uptime'                    # single quotes: runs on the REMOTE side
ssh lab "echo $HOSTNAME"                      # double quotes: $HOSTNAME expands LOCALLY first!
ssh lab 'echo $HOSTNAME'                      # single quotes: expands remotely

ssh lab 'bash -s' < local_script.sh           # run a LOCAL script on the remote server
ssh lab 'bash -s' -- arg1 arg2 < local_script.sh   # ...with arguments

ssh -t lab 'sudo apt update'                  # -t: give a terminal (needed for sudo password prompts)
```

Script-friendly options:
```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 lab 'uptime'
# BatchMode=yes   → never ask for a password; fail instead (a script can't type passwords)
# ConnectTimeout  → don't hang for minutes on a dead server
```

The exit code of `ssh` is the exit code of the **remote** command — so `if ssh host 'test -f /etc/nginx/nginx.conf'; then ...` works.

> ⚠️ The `while read` + ssh trap: ssh reads stdin and "eats" the rest of your server list.
> Always use `ssh -n` inside `while read` loops (or `< /dev/null`).

## 📖 Lesson 5.5 — Copying files: `scp` and `rsync`

```bash
scp app.conf lab:/tmp/                     # local → remote
scp lab:/var/log/syslog ./                 # remote → local
scp -r configs/ lab:/tmp/configs           # a whole directory
```

`rsync` is smarter: it only sends **what changed**, can resume, and can mirror deletes.
It's what you use for deploys and backups.

```bash
rsync -av src/ lab:/opt/app/               # -a archive (keeps permissions/times), -v verbose
rsync -avz --delete src/ lab:/opt/app/     # -z compress; --delete removes files gone from src (mirror)
rsync -av --dry-run --delete src/ lab:/opt/app/     # ALWAYS preview --delete first
rsync -av --exclude '.git' --exclude '*.log' src/ lab:/opt/app/
rsync -av lab:/var/backups/ ./backups/     # pull from remote
```

> ⚠️ **Trailing slash matters:** `rsync src/ dest` copies the *contents* of `src`;
> `rsync src dest` creates `dest/src`.

## 📖 Lesson 5.6 — Fleet operations

**One by one** (simple, readable output):
```bash
#!/usr/bin/env bash
set -uo pipefail
mapfile -t hosts < <(grep -vE '^\s*(#|$)' hosts.txt)

for host in "${hosts[@]}"; do
    printf '== %s ==\n' "$host"
    ssh -n -o BatchMode=yes -o ConnectTimeout=5 "$host" 'uptime' || echo "  ❌ unreachable"
done
```

**In parallel** (fast — results per host saved to files):
```bash
outdir=$(mktemp -d)
for host in "${hosts[@]}"; do
    ssh -n -o BatchMode=yes -o ConnectTimeout=5 "$host" 'uptime' > "$outdir/$host.out" 2>&1 &
done
wait
for host in "${hosts[@]}"; do printf '%-12s %s\n' "$host" "$(cat "$outdir/$host.out")"; done
```

Limit parallelism (be kind to your network/bastion):
```bash
printf '%s\n' "${hosts[@]}" | xargs -P 5 -I{} ssh -n -o BatchMode=yes {} 'hostname'
```

When fleet scripts start growing (packages, users, templated configs), that's exactly the job of
**Ansible** — which you'll find easy now, because it's SSH + YAML + Python.

## 📖 Lesson 5.7 — SSH security checklist (servers you manage)

In `/etc/ssh/sshd_config` (then `sudo systemctl reload ssh`):
```text
PermitRootLogin no              # log in as a normal user, then sudo
PasswordAuthentication no       # keys only (make sure YOUR key works first!)
```

- [ ] Ed25519 keys with a passphrase; private keys `600` and **never** in Git
- [ ] One key per person (so you can remove someone who leaves)
- [ ] Firewall: SSH only from known IPs or through a bastion/VPN
- [ ] `fail2ban` against brute force (Step 0 installed it as part of the bootstrap lab)
- [ ] Never ignore a "host identification has changed" warning

> 🔒 Before setting `PasswordAuthentication no` on a remote server, test key login in a **second**
> terminal while the first stays connected — otherwise you can lock yourself out.

---

## ⚠️ Common mistakes
- `"$VAR"` in double quotes expanding on your machine instead of the server
- `ssh` inside `while read` without `-n` → only the first host runs
- Running fleet scripts without `BatchMode=yes` → script hangs on a password prompt
- `rsync --delete` without `--dry-run` first; forgetting the trailing slash
- Private key permissions too open → `UNPROTECTED PRIVATE KEY FILE!`

---

## 🧪 Labs
Use `localhost` (alias `lab`) as your server. Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Key-based login
Install `openssh-server`, create an ed25519 key, `ssh-copy-id localhost`, add a `Host lab` entry in
`~/.ssh/config`, and prove `ssh -o BatchMode=yes lab true` exits with 0.

### Lab 2 ⭐⭐ — Remote facts
`remote_facts.sh HOST` runs **one** ssh connection that prints hostname, OS, kernel, uptime, disk `/`
and memory as `key=value` lines (use a quoted heredoc sent to `bash -s`). Exit 1 if the host is unreachable.

### Lab 3 ⭐⭐ — Deploy with rsync
`push_site.sh [-n] SRC_DIR HOST:DEST_DIR` syncs a folder with `rsync -az --delete`, supports
dry-run (`-n`), excludes `.git` and `*.log`, and prints a summary of changed files.

### Lab 4 ⭐⭐⭐ — Fleet runner
`fleet.sh [-p PARALLEL] HOSTS_FILE 'COMMAND'` runs a command on every host (skipping comments
and blank lines), in parallel with a limit, saving output per host. Print a table:
`HOST  STATUS  OUTPUT(first line)` and exit 1 if any host failed. Test it with a hosts file containing
`localhost`, `127.0.0.1`, `lab` and an unreachable host like `10.255.255.1`.

---

## ✅ Checkpoint
- [ ] I log in with keys and have a `~/.ssh/config` with aliases
- [ ] I know when variables expand locally vs remotely
- [ ] I use `ssh -n`, `BatchMode=yes` and `ConnectTimeout` in scripts
- [ ] I can sync folders with `rsync` safely (dry-run, trailing slash)
- [ ] I can run a command across a fleet in parallel and collect results

👉 Next: [Module 06 — Real DevOps Scripts](../06-real-devops-scripts/README.md)
