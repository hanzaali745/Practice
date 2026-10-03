#!/usr/bin/env bash
# Module 02 labs — reference solution. Run on your lab VM: sudo ./labs.sh   (safe to run again)
set -euo pipefail

groupadd -f devteam                                      # -f: fine if it already exists

# alice: developer with full sudo (password required), password must change every 90 days
id alice &> /dev/null || useradd --create-home --shell /bin/bash alice
usermod -aG devteam,sudo alice                           # -a = APPEND; without it you'd REPLACE all her groups
echo 'alice:Change-Me-Now-2026' | chpasswd               # lab only: real users set their own password
chage --lastday 0 alice                                  # ...and must change it at first login
chage --maxdays 90 alice

# bob: developer who may only restart nginx as root — nothing else
id bob &> /dev/null || useradd --create-home --shell /bin/bash --groups devteam bob
usermod -aG devteam bob
rule=$(mktemp)
echo 'bob ALL=(root) NOPASSWD: /usr/bin/systemctl restart nginx' > "$rule"
visudo -cf "$rule"                                       # ALWAYS validate: a broken sudoers file can lock everyone out
install -m 0440 -o root -g root "$rule" /etc/sudoers.d/bob-nginx
rm -f "$rule"

# svc-backup: a system account for a backup job — no login, no home directory
id svc-backup &> /dev/null || useradd --system --no-create-home --home-dir /nonexistent --shell /usr/sbin/nologin svc-backup

# carol left the company: lock the account and expire it (keep her files for now — they may be needed)
id carol &> /dev/null || useradd --create-home --shell /bin/bash carol
usermod --lock --expiredate 1970-01-02 carol

id alice; id bob; id svc-backup; sudo -l -U bob | tail -2; passwd -S carol; chage -l alice | sed -n 1,4p
