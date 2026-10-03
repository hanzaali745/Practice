#!/usr/bin/env bash
# Module 08 labs — reference solution. Run on your lab VM: sudo ./labs.sh   (safe to run again)
set -euo pipefail

# Lab 1 — what is listening, and who owns it?
mkdir -p /srv/lab
ss -tlnp | tee /srv/lab/listening.txt

# Lab 2 — firewall: deny incoming by default, allow only SSH and HTTP.
# ORDER MATTERS on a remote machine: allow SSH BEFORE enabling, or you lock yourself out.
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw --force enable
ufw status verbose

# Lab 3 — harden the SSH server with a drop-in (sshd uses the FIRST value it reads, and reads sshd_config.d first)
cat > /etc/ssh/sshd_config.d/50-lab-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
X11Forwarding no
EOF
install -d -m 755 /run/sshd
sshd -t                                        # test the config BEFORE reloading — a broken sshd = no way in
systemctl try-reload-or-restart ssh
sshd -T | grep -E '^(permitrootlogin|passwordauthentication|kbdinteractiveauthentication|maxauthtries|x11forwarding) '
