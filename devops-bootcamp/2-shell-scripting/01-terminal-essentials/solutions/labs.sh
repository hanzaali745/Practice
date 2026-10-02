#!/usr/bin/env bash
# Module 01 lab solutions — type each section by hand in your terminal to learn it.
# This file is Bash (not sh) because {a,b} brace expansion is a feature of your Bash terminal.

# Lab 1 — Project skeleton
mkdir -p myapp/{bin,config/{dev,prod},logs,scripts}
touch myapp/config/{dev,prod}/app.conf
find myapp

# Lab 2 — Permissions
touch deploy.sh secret.key
chmod 750 deploy.sh      # rwxr-x---
chmod 600 secret.key     # rw-------
ls -l deploy.sh secret.key

# Lab 3 — Log explorer
du -ah /var/log 2>/dev/null | sort -h | tail -n 5
tail -n 10 /var/log/syslog 2>/dev/null || journalctl -n 10 --no-pager 2>/dev/null || echo "no syslog here"
find /etc -maxdepth 2 -name "*.conf" 2>/dev/null | head

# Lab 4 — System report (by hand)
grep PRETTY_NAME /etc/os-release
uname -r
uptime
df -h /
free -h 2>/dev/null || grep MemTotal /proc/meminfo
hostname -I 2>/dev/null || ip -brief addr 2>/dev/null
id -u

# Clean up
rm -rf myapp deploy.sh secret.key
