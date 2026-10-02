#!/usr/bin/env bash
#
# bootstrap.sh — idempotent Ubuntu/Debian server baseline (cloud-init friendly)
# Usage: sudo bootstrap.sh [--dry-run]
#   Safe to run many times: every step checks before it changes anything.
#
set -euo pipefail

DRY_RUN=false
[[ ${1:-} == "--dry-run" ]] && DRY_RUN=true

PACKAGES=(curl git htop jq unzip fail2ban ufw)
DEPLOY_USER="deploy"

log() { printf '%s [bootstrap] %s\n' "$(date '+%F %T')" "$*" >&2; }
run() { if $DRY_RUN; then log "[dry-run] $*"; else "$@"; fi; }

$DRY_RUN || [[ $EUID -eq 0 ]] || { log "must run as root"; exit 1; }
command -v apt-get > /dev/null || { log "this script supports apt-based systems only"; exit 1; }

# 1. Packages — only install what's missing
missing=()
for pkg in "${PACKAGES[@]}"; do
    dpkg -s "$pkg" &> /dev/null || missing+=("$pkg")
done
if (( ${#missing[@]} > 0 )); then
    log "installing: ${missing[*]}"
    run apt-get update -qq
    run env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
else
    log "all packages already installed"
fi

# 2. Deploy user
if id "$DEPLOY_USER" &> /dev/null; then
    log "user $DEPLOY_USER exists"
else
    run useradd -m -s /bin/bash "$DEPLOY_USER"
fi

# 3. SSH hardening
sshd_config=/etc/ssh/sshd_config
if [[ -f $sshd_config ]] && ! grep -q '^PermitRootLogin no' "$sshd_config"; then
    run sed -i.bak 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$sshd_config"
    run systemctl reload ssh
else
    log "ssh root login already disabled (or sshd not installed)"
fi

# 4. Firewall
if command -v ufw > /dev/null && ! ufw status 2>/dev/null | grep -q "Status: active"; then
    run ufw allow OpenSSH
    run ufw --force enable
else
    log "firewall already active (or ufw missing)"
fi

log "bootstrap complete"
