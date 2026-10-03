#!/usr/bin/env bash
# first60.sh [OUTPUT_FILE] — the first 60 seconds on a sick Linux server: one read-only snapshot of everything
# that usually matters, saved to a file you can attach to the incident ticket.
#   sudo ./first60.sh                     → /tmp/first60-<host>-<time>.txt
# Nothing here changes the system. Commands that are missing are skipped, not fatal.
set -uo pipefail
out=${1:-/tmp/first60-$(hostname)-$(date +%Y%m%d-%H%M%S).txt}

section() {                              # section "title" command args...
    local title=$1
    shift
    printf '\n===== %s =====\n$ %s\n' "$title" "$*"
    if command -v "$1" > /dev/null 2>&1; then timeout 10 "$@" 2>&1; else echo "($1 not installed)"; fi
}

{
    echo "first60 report — $(hostname) — $(date -Is) — run by $(id -un)"
    section "Uptime and load (load > CPU count = work is queueing)" uptime
    section "CPU count" nproc
    section "Kernel messages: OOM kills, disk and network errors" bash -c 'dmesg -T 2>/dev/null | tail -20 || journalctl -k -n 20 --no-pager'
    section "Failed services" systemctl --failed --no-pager
    section "Memory (look at 'available', not 'free')" free -h
    section "CPU, memory, swap, IO per second (5 samples)" vmstat 1 5
    section "Top CPU consumers" bash -c 'ps aux --sort=-%cpu | head -8'
    section "Top memory consumers" bash -c 'ps aux --sort=-%mem | head -8'
    section "Disk space" df -h -x tmpfs -x devtmpfs -x overlay
    section "Inodes" df -i -x tmpfs -x devtmpfs -x overlay
    section "Small/tmpfs mounts too (a full /run or log tmpfs breaks things)" df -h -t tmpfs
    section "Deleted files still held open (space df counts but du can't see)" bash -c 'lsof -nP +L1 2>/dev/null | head -10'
    section "Disk IO per device (%util near 100 = saturated)" iostat -xz 1 2
    section "Listening sockets and their processes" ss -tlnp
    section "Connection states summary" ss -s
    section "Errors in the journal, last 15 minutes" journalctl -p err --since "-15min" --no-pager -n 30
    section "Recent logins and reboots" last -n 5
} > "$out" 2>&1

echo "📄 report: $out ($(wc -l < "$out") lines)"
grep -E '^(=====|\$)' "$out" > /dev/null && echo "Start reading at: load, failed services, dmesg, disk — then follow the evidence."
