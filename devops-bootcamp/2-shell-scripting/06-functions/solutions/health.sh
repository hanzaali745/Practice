#!/bin/sh
# Lab 4 — health check built from small functions
# Usage: sh health.sh [process...]
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib/logging.sh
. "$SCRIPT_DIR/lib/logging.sh"

DISK_MAX="${DISK_MAX:-90}"
MEM_MAX="${MEM_MAX:-90}"

check_disk() {
    disk_used=$(df -P / | awk 'NR == 2 { sub("%", "", $5); print $5 }')
    if [ "$disk_used" -lt "$DISK_MAX" ]; then
        ok "disk / at ${disk_used}%"
    else
        error "disk / at ${disk_used}% (max ${DISK_MAX}%)"
        return 1
    fi
}

check_memory() {
    mem_used=$(free | awk '/^Mem:/ { printf "%d", $3 / $2 * 100 }')
    if [ "$mem_used" -lt "$MEM_MAX" ]; then
        ok "memory at ${mem_used}%"
    else
        error "memory at ${mem_used}% (max ${MEM_MAX}%)"
        return 1
    fi
}

check_load() {
    load=$(cut -d' ' -f1 /proc/loadavg)
    cores=$(nproc)
    # awk does the decimal comparison: exit 0 (true) when load < cores
    if awk -v l="$load" -v c="$cores" 'BEGIN { exit !(l < c) }'; then
        ok "load $load (cores $cores)"
    else
        error "load $load is higher than cores $cores"
        return 1
    fi
}

check_process() {
    if pgrep -x "$1" > /dev/null; then
        ok "process $1 running"
    else
        error "process $1 NOT running"
        return 1
    fi
}

main() {
    failures=0
    check_disk   || failures=$((failures + 1))
    check_memory || failures=$((failures + 1))
    check_load   || failures=$((failures + 1))
    for proc in "$@"; do
        check_process "$proc" || failures=$((failures + 1))
    done

    if [ "$failures" -gt 0 ]; then
        error "$failures check(s) failed"
        exit 1
    fi
    ok "all checks passed"
}

main "$@"
