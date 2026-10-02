# shellcheck shell=bash
# opsctl health — disk, memory, load and process checks. Exit 1 if any check fails.

_health_disk() {
    local max="$1" mount usage failed=0
    while read -r usage mount; do
        usage="${usage%\%}"
        if (( usage >= max )); then
            error "disk $mount at ${usage}% (max ${max}%)"; failed=1
        else
            ok "disk $mount at ${usage}%"
        fi
    done < <(df -P -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null | awk 'NR > 1 {print $5, $6}')
    return "$failed"
}

_health_memory() {
    local max="$1" used
    used=$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {printf "%d", (t - a) / t * 100}' /proc/meminfo)
    if (( used >= max )); then error "memory at ${used}% (max ${max}%)"; return 1; fi
    ok "memory at ${used}%"
}

_health_load() {
    local load cores
    load=$(cut -d' ' -f1 /proc/loadavg)
    cores=$(nproc)
    if awk -v l="$load" -v c="$cores" 'BEGIN { exit !(l >= c) }'; then
        error "load $load >= cores $cores"; return 1
    fi
    ok "load $load (cores $cores)"
}

_health_process() {
    if pgrep -x "$1" > /dev/null; then ok "process $1 running"; return 0; fi
    error "process $1 NOT running"; return 1
}

cmd_health() {
    local disk_max=90 mem_max=90 opt failures=0 p
    local -a processes=()
    OPTIND=1
    while getopts ":d:m:s:h" opt; do
        case "$opt" in
            d) disk_max="$OPTARG" ;;
            m) mem_max="$OPTARG" ;;
            s) processes+=("$OPTARG") ;;
            h) echo "Usage: opsctl health [-d DISK_MAX] [-m MEM_MAX] [-s PROCESS]..."; return 0 ;;
            *) die "usage: opsctl health [-d DISK_MAX] [-m MEM_MAX] [-s PROCESS]..." ;;
        esac
    done
    is_positive_int "$disk_max" || die "-d must be a positive integer"
    is_positive_int "$mem_max" || die "-m must be a positive integer"

    _health_disk "$disk_max" || failures=$(( failures + 1 ))
    _health_memory "$mem_max" || failures=$(( failures + 1 ))
    _health_load || failures=$(( failures + 1 ))
    for p in "${processes[@]}"; do
        _health_process "$p" || failures=$(( failures + 1 ))
    done

    if (( failures > 0 )); then
        error "$failures check(s) failed"
        return 1
    fi
    ok "all checks passed"
}
