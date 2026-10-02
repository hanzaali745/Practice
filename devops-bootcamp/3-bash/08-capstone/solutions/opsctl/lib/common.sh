# shellcheck shell=bash
# Shared helpers for opsctl. Sourced, never executed.

DRY_RUN=false

if [[ -t 2 ]]; then
    _C_RED=$'\e[31m' _C_YELLOW=$'\e[33m' _C_GREEN=$'\e[32m' _C_RESET=$'\e[0m'
else
    _C_RED="" _C_YELLOW="" _C_GREEN="" _C_RESET=""
fi

_log() {
    local level="$1" color="$2"; shift 2
    local line
    line="$(date '+%F %T') [$level] $*"
    printf '%s%s%s\n' "$color" "$line" "$_C_RESET" >&2
    if [[ -n ${OPSCTL_LOG_FILE:-} ]]; then
        printf '%s\n' "$line" >> "$OPSCTL_LOG_FILE"
    fi
}

info()  { _log "INFO " "" "$@"; }
ok()    { _log " OK  " "$_C_GREEN" "$@"; }
warn()  { _log "WARN " "$_C_YELLOW" "$@"; }
error() { _log "ERROR" "$_C_RED" "$@"; }
die()   { error "$@"; exit 1; }

# Run a state-changing command, or just log it in dry-run mode.
run() {
    if $DRY_RUN; then
        info "[dry-run] $*"
    else
        "$@"
    fi
}

require_cmd() {
    local c
    for c in "$@"; do
        command -v "$c" > /dev/null || die "required command not found: $c"
    done
}

is_positive_int() { [[ ${1:-} =~ ^[1-9][0-9]*$ ]]; }
