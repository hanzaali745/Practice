#!/usr/bin/env bash
# Module 01 labs — reference solution. Run on your lab VM: sudo ./labs.sh   (safe to run again)
set -euo pipefail

# Lab 2 — links: one file, two names (hard link) and a pointer to a name (symlink)
mkdir -p /srv/lab/links
cd /srv/lab/links
[[ -f original.txt ]] || echo "the original" > original.txt
ln -f original.txt hard.txt          # same inode: same data, two names
ln -sfn original.txt soft.txt        # a separate tiny file that contains the PATH "original.txt"
ls -li /srv/lab/links

# Lab 3 — find: regular files over 1 MiB under /usr, on this file system only
mkdir -p /srv/lab/find
find /usr -xdev -type f -size +1M 2> /dev/null | sort > /srv/lab/find/big-files.txt
echo "$(wc -l < /srv/lab/find/big-files.txt) big files listed"

# Lab 4 — back up /etc, keeping owners and permissions, with paths relative to /
mkdir -p /var/backups/lab
tar --create --gzip --preserve-permissions --file /var/backups/lab/etc-backup.tar.gz -C / etc 2> /dev/null || true
tar -tvzf /var/backups/lab/etc-backup.tar.gz etc/shadow etc/hostname
# restore ONE file somewhere safe to compare (never straight over /etc):
mkdir -p /tmp/restore && tar -xzpf /var/backups/lab/etc-backup.tar.gz -C /tmp/restore etc/hostname && diff /etc/hostname /tmp/restore/etc/hostname && echo "restore OK"
