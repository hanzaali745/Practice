# shellcheck shell=bash
# Lab 3 — reusable logging library. Source it, don't run it.
# Set LOG_FILE to also append plain-text messages to a file.

if [[ -t 2 ]]; then
    _RED=$'\e[31m' _GREEN=$'\e[32m' _YELLOW=$'\e[33m' _RESET=$'\e[0m'
else
    _RED="" _GREEN="" _YELLOW="" _RESET=""   # no colours when not a terminal
fi

_log() {
    local level="$1" color="$2"; shift 2
    local line
    line="$(date '+%F %T') [$level] $*"
    printf '%s%s%s\n' "$color" "$line" "$_RESET" >&2
    if [[ -n ${LOG_FILE:-} ]]; then
        printf '%s\n' "$line" >> "$LOG_FILE"
    fi
}

log()   { _log "INFO " "" "$@"; }
ok()    { _log " OK  " "$_GREEN" "$@"; }
warn()  { _log "WARN " "$_YELLOW" "$@"; }
error() { _log "ERROR" "$_RED" "$@"; }
die()   { error "$@"; exit 1; }
