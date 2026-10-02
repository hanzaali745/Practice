#!/usr/bin/env bash
# Lab 4 — production-style job wrapper: strict mode, lock, traps, logging.
# Usage: ./lab4_safe_job.sh [seconds_of_work]
# Prove the lock: run it twice at the same time in two terminals.
set -euo pipefail

readonly NAME="safe_job"
readonly LOCK_FILE="/tmp/${NAME}.lock"
readonly LOG_FILE="${LOG_FILE:-/tmp/${NAME}.log}"
work_seconds="${1:-3}"

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$$" "$*" | tee -a "$LOG_FILE" >&2; }

on_exit() {
    local status=$?
    if (( status == 0 )); then log "finished OK"; else log "FAILED with exit code $status"; fi
}
trap on_exit EXIT
trap 'log "error on line $LINENO: $BASH_COMMAND"' ERR
trap 'log "terminated"; exit 143' TERM
trap 'log "interrupted"; exit 130' INT

exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    log "another instance is running, exiting"
    exit 1
fi

log "lock acquired, working for ${work_seconds}s"
sleep "$work_seconds"
log "work complete"
