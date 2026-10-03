# Linux Module 03 — Permissions in Depth 🟡

## 🎯 Objectives
- Read and set permissions in symbolic and octal form — including what `r`, `w`, `x` mean on **directories**
- Control default permissions with `umask`
- Use the special bits: **setuid**, **setgid** (shared team directories) and **sticky** (shared drop boxes)
- Grant extra users or groups access with **ACLs**, including default ACLs for new files
- Make files immutable with `chattr`, and know where capabilities and SELinux/AppArmor fit
- Audit a system for risky permissions

## 🧠 Why DevOps engineers care
"Permission denied" is the most common error you'll debug, and "world-writable" or "runs as root" are the most common
security findings. Container volumes, CI runners writing to shared folders, web servers reading app files, backup jobs
reading everything — all of them are permission designs.

---

## 📖 Lesson 3.1 — The basics, properly

```
-rwxr-x---  1 alice devteam  report.sh
 │└┬┘└┬┘└┬┘
 │ u  g  o        user (owner) · group · others          r=4 w=2 x=1  →  rwx r-x --- = 750
 └ type
```
| | on a **file** | on a **directory** |
|---|---|---|
| `r` | read the contents | **list** the names in it |
| `w` | change the contents | **create, delete, rename** entries (even files you can't write!) |
| `x` | run it | **enter** it / reach anything inside by name |

To open `/srv/a/b/file` you need `x` on **every** directory on the path (`namei -l /srv/a/b/file` shows them all).
```bash
chmod 640 file; chmod u+x,g-w,o= file; chmod -R g+rX dir   # capital X: x only on directories (and already-executable files)
chown alice:devteam file; chgrp devteam file
```

## 📖 Lesson 3.2 — umask: the default

New files start from `666` (dirs `777`) **minus** the umask. `umask` → `0022` gives `644`/`755`; `umask 027` gives
`640`/`750` (nothing for others) — a good default for servers and service accounts (`UMask=0027` in a systemd unit).

## 📖 Lesson 3.3 — The special bits

| Bit | Octal | On a file | On a directory |
|-----|-------|-----------|----------------|
| **setuid** | `4000` | runs as the file's **owner** (`/usr/bin/passwd` runs as root to edit `/etc/shadow`) | — |
| **setgid** | `2000` | runs as the file's group | **new files inherit the directory's group** — perfect for team folders |
| **sticky** | `1000` | — | only a file's owner may delete/rename it (that's how `/tmp` works: `drwxrwxrwt`) |

```bash
chmod 2770 /srv/devteam          # setgid team dir: rwx for owner and group, nothing for others
chmod 1777 /srv/dropbox          # everyone writes, nobody deletes other people's files
find / -xdev -type f -perm -4000 # audit: every setuid program (each is a potential privilege escalation)
```
Setuid on **scripts** is ignored by Linux; setuid on your own binaries is almost never the answer — use sudo rules.

## 📖 Lesson 3.4 — ACLs: more than one group

Classic permissions have one owner and one group. **ACLs** add entries for extra users/groups:
```bash
setfacl -m u:auditor:rx /srv/devteam        # auditor may read, without joining the group
setfacl -m g:devteam:rwx /srv/devteam
setfacl -d -m g:devteam:rwx /srv/devteam    # DEFAULT ACL: applied to every new file/dir created inside
getfacl /srv/devteam                        # ls -l shows a "+" when ACLs exist: drwxrws---+
setfacl -x u:auditor /srv/devteam; setfacl -b file   # remove one entry / all ACLs
```
A default ACL makes new files group-writable **whatever the creator's umask is** — the reliable way to share a folder.
The **mask** entry caps all group/named entries (`chmod g-w` changes the mask!).

## 📖 Lesson 3.5 — Beyond permissions

- **File attributes:** `chattr +i file` = immutable (not even root can change or delete it until `chattr -i`);
  `chattr +a` = append-only (logs). `lsattr` shows them.
- **Capabilities:** slices of root's power for one program: `setcap cap_net_bind_service=+ep /usr/bin/app` lets it bind
  port 80 without running as root (`getcap -r /usr 2>/dev/null` lists them). Containers drop capabilities the same way.
- **Mandatory access control:** AppArmor (Ubuntu, `aa-status`) and SELinux (RHEL, `getenforce`, `ls -Z`) confine
  programs even when classic permissions allow. A "Permission denied" that makes no sense → check their logs.

---

## ⚠️ Common mistakes
- `chmod -R 777` to fix anything — now every process and user can rewrite it
- Forgetting `x` on a parent directory and blaming the file's mode
- Team folders without setgid/default ACLs: half the files end up in the wrong group or read-only for colleagues
- `chmod -R 755` on a tree with private keys or `.env` files
- Not noticing the ACL `+` in `ls -l` and wondering why access differs from the mode bits

---

## 🧪 Labs
On your lab VM, after Module 02 (needs alice, bob and devteam). Reference solution: [`solutions/labs.sh`](solutions/labs.sh).
Check: `sudo lab/check.sh 03`.

### Lab 1 ⭐⭐ — A team folder
`/srv/devteam`: owned by root, group `devteam`, mode `2770`. A file **alice** creates must be writable by **bob**,
whatever alice's umask is (hint: default ACL). Test it with `sudo -u alice ...` and `sudo -u bob ...`.

### Lab 2 ⭐⭐ — A read-only auditor
Create user **auditor**: can list and read `/srv/devteam` (and new files in it), can't write. Don't add them to `devteam`.

### Lab 3 ⭐ — The drop box
`/srv/dropbox`: everyone can create files; nobody can delete someone else's. Prove bob can't delete alice's file.

### Lab 4 ⭐ — Locked
Create `/srv/devteam/RELEASE-LOCK` and make it immutable. Try to delete it as root. Then explain when you'd use this.

### Lab 5 ⭐⭐ — Audit
Write every setuid program on the root file system to `/srv/lab/setuid.txt`. Pick three and explain why each needs it.
Also find any world-writable files outside `/tmp`, `/var/tmp` and `/dev`.

---

## ✅ Checkpoint
- [ ] I know what r/w/x mean on directories and debug paths with `namei -l`
- [ ] I can set up a shared team folder with setgid and default ACLs
- [ ] I can explain setuid, setgid and sticky with examples
- [ ] I can use chattr, and I know where capabilities and AppArmor/SELinux fit
- [ ] `sudo lab/check.sh 03` passes

👉 Next: [Module 04 — Packages & Software](../04-packages/README.md)
