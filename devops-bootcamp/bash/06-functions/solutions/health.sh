#!/usr/bin/env bash
# Lab 4 — health check built from small functions
# Usage: ./health.sh [service...]
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

DISK_MAX="${DISK_MAX:-90}"
MEM_MAX="${MEM_MAX:-90}"

check_disk() {
    local usage
    usage=$(df --output=pcent / | tail -1 | tr -dc '0-9')
    if (( usage < DISK_MAX )); then ok "disk / at ${usage}%"; else error "disk / at ${usage}%"; return 1; fi
}

check_memory() {
    local used
    used=$(free | awk '/^Mem:/ { printf "%d", $3 / $2 * 100 }')
    if (( used < MEM_MAX )); then ok "memory at ${used}%"; else error "memory at ${used}%"; return 1; fi
}

check_load() {
    local load cores
    load=$(cut -d' ' -f1 /proc/loadavg)
    cores=$(nproc)
    if awk -v l="$load" -v c="$cores" 'BEGIN { exit !(l < c) }'; then
        ok "load $load (cores $cores)"
    else
        error "load $load exceeds cores $cores"; return 1
    fi
}

check_service() {
    local name="$1"
    if pgrep -x "$name" &>/dev/null; then ok "process $name running"; else error "process $name not running"; return 1; fi
}

main() {
    local failures=0 svc
    check_disk   || (( ++failures ))
    check_memory || (( ++failures ))
    check_load   || (( ++failures ))
    for svc in "$@"; do
        check_service "$svc" || (( ++failures ))
    done

    if (( failures > 0 )); then
        error "$failures check(s) failed"
        exit 1
    fi
    ok "all checks passed"
}

main "$@"
