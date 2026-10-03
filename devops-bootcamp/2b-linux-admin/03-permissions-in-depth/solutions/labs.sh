#!/usr/bin/env bash
# Module 03 labs — reference solution (needs module 02's users). Run: sudo ./labs.sh   (safe to run again)
set -euo pipefail
s=/srv/devteam
id auditor &> /dev/null || useradd --create-home --shell /bin/bash auditor

# Lab 1 — a shared team directory: group devteam, setgid so new files inherit the group, nobody else
mkdir -p "$s"
chattr -i "$s/RELEASE-LOCK" 2> /dev/null || true        # (re-runs: allow changes inside again)
chown root:devteam "$s"
chmod 2770 "$s"
# default ACLs: every NEW file is group-writable for devteam whatever the creator's umask is
setfacl -m g:devteam:rwx "$s"
setfacl -d -m g:devteam:rwx "$s"

# Lab 2 — an auditor may read, never write (an ACL for one extra user, without changing the group)
setfacl -m u:auditor:rx "$s"
setfacl -d -m u:auditor:rx "$s"
getfacl -p "$s"

# Lab 3 — a drop box everyone can write to, but only owners can delete their files (sticky bit, like /tmp)
mkdir -p /srv/dropbox
chmod 1777 /srv/dropbox

# Lab 4 — a file nobody (not even root, until chattr -i) can change or delete
touch "$s/RELEASE-LOCK"
chattr +i "$s/RELEASE-LOCK"
lsattr "$s/RELEASE-LOCK"

# Lab 5 — audit: which programs run with their OWNER's rights (setuid)?
mkdir -p /srv/lab
find / -xdev -type f -perm -4000 2> /dev/null | sort > /srv/lab/setuid.txt
cat /srv/lab/setuid.txt
