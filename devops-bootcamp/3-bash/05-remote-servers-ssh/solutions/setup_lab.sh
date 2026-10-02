#!/usr/bin/env bash
# Lab 1 — turn your own machine into an SSH "practice server" (run once)
# Usage: ./setup_lab.sh
set -euo pipefail

if ! command -v sshd > /dev/null && [[ ! -x /usr/sbin/sshd ]]; then
    echo "Installing openssh-server and rsync (needs sudo)..."
    sudo apt-get update -qq
    sudo apt-get install -y openssh-server rsync
fi

# Start the SSH server (systemd on normal Ubuntu, `service` on WSL)
sudo systemctl enable --now ssh 2> /dev/null || sudo service ssh start

mkdir -p ~/.ssh && chmod 700 ~/.ssh
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519 -C "$USER@devops-lab"   # no passphrase: LAB ONLY
fi

# Authorise our own key for localhost logins (idempotent: only add once)
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
grep -qxF "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys || cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# Trust localhost's host key without an interactive prompt
ssh-keyscan -H localhost 127.0.0.1 2> /dev/null >> ~/.ssh/known_hosts

# Add the `lab` alias once
touch ~/.ssh/config && chmod 600 ~/.ssh/config
if ! grep -q '^Host lab$' ~/.ssh/config; then
    printf '\nHost lab\n    HostName localhost\n    IdentityFile ~/.ssh/id_ed25519\n' >> ~/.ssh/config
fi

if ssh -o BatchMode=yes -o ConnectTimeout=5 lab true; then
    echo "✅ ssh lab works with a key — you're ready for the labs"
else
    echo "❌ key login to lab failed — check: sudo systemctl status ssh" >&2
    exit 1
fi
