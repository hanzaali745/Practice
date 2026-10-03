#!/usr/bin/env bash
#
# fleet.sh — manage the Ansible practice fleet (3 Ubuntu containers with systemd + SSH)
# Usage: fleet.sh up | down | reset | status | ssh NODE
#
set -euo pipefail
self=$(readlink -f "$0")
cd "$(dirname "$self")"

log() { printf '[fleet] %s\n' "$*" >&2; }

ensure_key() {
    if [[ ! -f .ssh/id_ed25519 ]]; then
        mkdir -p .ssh && chmod 700 .ssh
        ssh-keygen -q -t ed25519 -N "" -C "ansible-lab" -f .ssh/id_ed25519
        log "created lab SSH key in lab-fleet/.ssh/"
    fi
    chmod 600 .ssh/id_ed25519
}

wait_ssh() {
    local port
    for port in 2221 2222 2223; do
        for _ in {1..60}; do
            if ssh -q -i .ssh/id_ed25519 -p "$port" -o BatchMode=yes -o ConnectTimeout=2 \
                   -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null devops@127.0.0.1 true; then
                continue 2
            fi
            sleep 1
        done
        log "node on port $port did not accept SSH in time"; exit 1
    done
}

case "${1:-}" in
    up)
        ensure_key
        log "starting the fleet (the first build takes a few minutes)..."
        if ! docker compose up -d --build --quiet-pull > .fleet-up.log 2>&1; then
            cat .fleet-up.log >&2; exit 1
        fi
        wait_ssh
        log "fleet is up: web1 (2221), web2 (2222), db1 (2223) — try: ansible -i inventory.ini fleet -m ping"
        ;;
    down)
        docker compose down --volumes > /dev/null
        log "fleet removed"
        ;;
    reset)
        "$self" down
        "$self" up
        ;;
    status)
        docker compose ps --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
        ;;
    ssh)
        node="${2:?Usage: fleet.sh ssh web1|web2|db1}"
        port=$(awk -v n="$node" '$1 == n { sub("ansible_port=", "", $2); print $2 }' inventory.ini)
        [[ -n $port ]] || { log "unknown node: $node"; exit 2; }
        exec ssh -i .ssh/id_ed25519 -p "$port" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null devops@127.0.0.1
        ;;
    *)
        sed -n '3,4p' "$0" | sed 's/^# \{0,1\}//' >&2
        exit 2
        ;;
esac
