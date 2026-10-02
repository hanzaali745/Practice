# shellcheck shell=sh
# Lab 3 — reusable logging library. Load it with:  . "$SCRIPT_DIR/lib/logging.sh"
# Set LOG_FILE to also append every message to a file.

_log() {
    _log_line="$(date '+%F %T') [$1] $2"
    printf '%s\n' "$_log_line" >&2
    if [ -n "${LOG_FILE:-}" ]; then
        printf '%s\n' "$_log_line" >> "$LOG_FILE"
    fi
}

log()   { _log "INFO " "$*"; }
ok()    { _log " OK  " "$*"; }
warn()  { _log "WARN " "$*"; }
error() { _log "ERROR" "$*"; }
die()   { error "$*"; exit 1; }
