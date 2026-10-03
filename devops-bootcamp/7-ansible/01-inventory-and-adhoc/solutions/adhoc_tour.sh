#!/usr/bin/env bash
# Labs 1-4 as a guided tour of ad-hoc commands (run from this folder, with the fleet up)
set -euo pipefail
cd "$(dirname "$0")"

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

step "Lab 1: ping + inventory"
ansible fleet -m ping -o
ansible-inventory --graph
ansible-inventory --host db1

step "Lab 2: uptime, kernel, disk, distro facts"
ansible fleet -o -a "uptime"
ansible fleet -o -a "uname -r"
ansible web -o -m shell -a "df -h / | tail -n 1"
ansible fleet -m setup -a "filter=ansible_distribution_version"

step "Lab 3: idempotence — apt module (2nd run should be ok, not changed)"
ansible fleet -b -m apt -a "name=tree,jq state=present update_cache=true cache_valid_time=3600" | grep -E "CHANGED|SUCCESS" || true
ansible fleet -b -m apt -a "name=tree,jq state=present" | grep -E "CHANGED|SUCCESS" || true
step "Lab 3: command module ALWAYS reports changed"
ansible fleet -b -o -a "apt-get install -y tree" | grep -oE "^[a-z0-9]+ \| [A-Z]+" || true

step "Lab 4: YAML inventory with a prod group"
ansible-inventory -i inventory.yaml --graph
ansible prod -i inventory.yaml -m debug -a "var=env"
