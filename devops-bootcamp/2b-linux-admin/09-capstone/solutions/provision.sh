#!/usr/bin/env bash
# provision.sh — turn a fresh Ubuntu 24.04 VM into the finished lab server in ONE idempotent run:
# every module's lab, in dependency order. Run it twice: the second run must succeed and change nothing important.
#   sudo ./provision.sh && sudo ../../lab/check.sh all
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "run me with sudo" >&2; exit 2; }
course=$(cd "$(dirname "$0")/../.." && pwd)
log=/var/log/lab-provision.log

step() {
    local module=$1
    printf '▶ %-32s' "$module"
    if "$course/$module/solutions/labs.sh" >> "$log" 2>&1; then echo "✅"; else echo "❌ (see $log)"; exit 1; fi
}

echo "=== provision $(date -Is)" >> "$log"
step 01-filesystem-and-files
step 02-users-groups-sudo
step 03-permissions-in-depth
step 04-packages
step 05-services-boot-time
step 06-storage
step 07-processes-and-kernel
step 08-networking-and-hardening
echo "✅ provisioned — now: sudo $course/lab/check.sh all"
