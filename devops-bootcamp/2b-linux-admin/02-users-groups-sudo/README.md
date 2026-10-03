# Linux Module 02 — Users, Groups & sudo 🟢

## 🎯 Objectives
- Read `/etc/passwd`, `/etc/shadow` and `/etc/group` and know what every field means
- Create, modify, lock, expire and delete users; manage groups and memberships
- Tell human accounts from **system accounts**, and create service users that can't log in
- Set password policies with `chage`
- Grant **least-privilege** sudo rules in `/etc/sudoers.d/` — safely, with `visudo`
- Audit who can do what, and who logged in

## 🧠 Why DevOps engineers care
Every service should run as its own unprivileged user; every person should have their own account and exactly the
rights their job needs. When someone leaves, their access must go — today. Ansible's `user` module, Kubernetes'
`runAsUser`, Docker's `USER` and cloud IAM all build on these same ideas.

---

## 📖 Lesson 2.1 — Where users live

```
/etc/passwd   alice:x:1001:1001:Alice Smith:/home/alice:/bin/bash
              name  pw UID  GID  comment     home        login shell     (readable by all — no passwords here)
/etc/shadow   alice:$y$j9T$...:20000:0:90:7:::
              name  hash     last-change min max warn inactive expire    (root only)
/etc/group    devteam:x:1002:alice,bob                                    (supplementary members)
```
- **UID 0** is root. **1–999** are system accounts (services). **1000+** are people.
- Each user has one **primary** group (GID in passwd, owns new files) and any number of **supplementary** groups.
- `getent passwd alice` / `getent group devteam` read the same data from any source (files, LDAP, SSSD).
- `id alice` shows UID, GID and every group. Group changes apply at the **next login**.

## 📖 Lesson 2.2 — Managing users and groups

```bash
sudo useradd --create-home --shell /bin/bash alice     # Debian also has the friendlier interactive "adduser"
sudo passwd alice                                      # set a password
sudo groupadd devteam
sudo usermod -aG devteam alice                         # -a APPENDS. Forget -a and alice loses all other groups!
sudo gpasswd -d alice devteam                          # remove from a group
sudo usermod --lock alice / --unlock alice             # lock the password (key logins may still work!)
sudo usermod --expiredate 1970-01-02 alice             # expire the account: no login at all, any method
sudo usermod -s /usr/sbin/nologin alice                # no interactive shell
sudo userdel -r alice                                  # delete user AND home (keep the home if data may be needed)
sudo useradd --system --no-create-home --home-dir /nonexistent --shell /usr/sbin/nologin svc-backup   # a service account
```
**Offboarding someone:** lock + expire the account, remove their SSH keys (`~/.ssh/authorized_keys`), remove their
sudo rules, check their cron jobs (`crontab -l -u NAME`) and running processes, and rotate shared secrets they knew.

## 📖 Lesson 2.3 — Password policy

```bash
sudo chage -l alice                  # current policy
sudo chage --maxdays 90 alice        # must change every 90 days
sudo chage --lastday 0 alice         # must change at next login
```
System-wide defaults live in `/etc/login.defs` (`PASS_MAX_DAYS`...) and PAM (`/etc/pam.d/`, `pam_pwquality` for
strength). On servers, people should log in with **SSH keys**, not passwords (Module 08).

## 📖 Lesson 2.4 — su and sudo

- `su - alice` becomes alice (needs **alice's** password); `su -` becomes root (needs root's password — usually disabled on Ubuntu).
- `sudo cmd` runs one command as root, authenticated with **your own** password, logged in `/var/log/auth.log`.
  Members of the `sudo` group (Ubuntu) / `wheel` (RHEL) may run anything.
- `sudo -i` a root shell (use sparingly), `sudo -u bob cmd` run as another user, `sudo -l` what may I run?

**Rules go in `/etc/sudoers.d/`, one file per purpose, edited with visudo:**
```bash
sudo visudo -f /etc/sudoers.d/bob-nginx
# user  host=(run-as)  options: command (full path!)
bob     ALL=(root)     NOPASSWD: /usr/bin/systemctl restart nginx
%devteam ALL=(root)    /usr/bin/journalctl -u nginx *
```
`visudo` refuses to save a file with a syntax error — a broken sudoers file can lock **everyone** out of sudo. Files
must be mode `0440`; names must not contain a `.` or end in `~` (those are ignored). Never grant `ALL` "to make it work",
and beware rules for editors, shells or `less` — they can spawn a root shell.

## 📖 Lesson 2.5 — Auditing

```bash
getent group sudo                           # who has full sudo?
sudo grep -r . /etc/sudoers.d/              # every extra rule
sudo -l -U bob                              # what may bob run?
awk -F: '$3 >= 1000 {print $1}' /etc/passwd # human accounts
last -n 10; lastlog | grep -v Never         # recent logins
sudo grep 'sudo:' /var/log/auth.log | tail  # recent sudo use
```

---

## ⚠️ Common mistakes
- `usermod -G` without `-a` — silently removes every other group
- Editing `/etc/sudoers` with a normal editor and breaking sudo for everyone
- `ALL=(ALL) NOPASSWD: ALL` for convenience; sudo rules for scripts users can edit
- Locking a password and thinking the person can't get in (SSH keys still work — expire the account)
- Running services as root or as a real person's account; sharing one account between people

---

## 🧪 Labs
On your lab VM. Reference solution: [`solutions/labs.sh`](solutions/labs.sh). Check: `sudo lab/check.sh 02`.

### Lab 1 ⭐ — Read the files
Find your own entry in `/etc/passwd`, `/etc/shadow` and `/etc/group` and explain every field. Which accounts are
system accounts? Which have a real login shell?

### Lab 2 ⭐⭐ — A team
Create group `devteam`. Create **alice** (home, bash, in `devteam` and `sudo`, must change her password at first login
and then every 90 days) and **bob** (home, bash, in `devteam`, **not** in `sudo`).

### Lab 3 ⭐⭐ — Least-privilege sudo
Let **bob** run exactly `/usr/bin/systemctl restart nginx` as root without a password — nothing else. Put it in
`/etc/sudoers.d/bob-nginx` (validate it first!). Prove with `sudo -l -U bob`.

### Lab 4 ⭐⭐ — Service account and offboarding
Create the system user **svc-backup** (UID below 1000, no home, no login shell). Then **carol** "leaves the company":
create her, then lock and expire her account. Write down every other step real offboarding would need.

---

## ✅ Checkpoint
- [ ] I can explain every field of passwd, shadow and group
- [ ] I can create, change, lock, expire and remove users and groups (and I always use `usermod -aG`)
- [ ] I create service accounts that can't log in
- [ ] I write narrow sudo rules in `/etc/sudoers.d/` with visudo
- [ ] `sudo lab/check.sh 02` passes

👉 Next: [Module 03 — Permissions in Depth](../03-permissions-in-depth/README.md)
