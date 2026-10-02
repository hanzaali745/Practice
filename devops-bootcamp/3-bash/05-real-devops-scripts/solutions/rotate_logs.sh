#!/usr/bin/env bash
#
# rotate_logs.sh — compress old logs and delete very old archives
# Usage: rotate_logs.sh [-n] [-c DAYS] [-d DAYS] DIR
#   -c DAYS  gzip *.log files older than DAYS (default 1)
#   -d DAYS  delete *.gz files older than DAYS (default 30)
#
set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
DRY_RUN=false
COMPRESS_DAYS=1
DELETE_DAYS=30

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$SCRIPT_NAME" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
run() { if $DRY_RUN; then log "[dry-run] $*"; else "$@"; fi; }
usage() { sed -n '3,6p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

main() {
    local opt
    while getopts ":nc:d:h" opt; do
        case "$opt" in
            n) DRY_RUN=true ;;
            c) COMPRESS_DAYS="$OPTARG" ;;
            d) DELETE_DAYS="$OPTARG" ;;
            *) usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    [[ $# -eq 1 ]] || usage
    local dir="$1"
    [[ -d $dir ]] || die "not a directory: $dir"

    local before after file compressed=0 deleted=0
    before=$(du -sk "$dir" | cut -f1)

    while IFS= read -r -d '' file; do
        log "compressing $file"
        run gzip -f "$file"
        compressed=$(( compressed + 1 ))
    done < <(find "$dir" -type f -name "*.log" -mtime +"$(( COMPRESS_DAYS - 1 ))" -print0)

    while IFS= read -r -d '' file; do
        log "deleting $file"
        run rm -f "$file"
        deleted=$(( deleted + 1 ))
    done < <(find "$dir" -type f -name "*.gz" -mtime +"$(( DELETE_DAYS - 1 ))" -print0)

    after=$(du -sk "$dir" | cut -f1)
    log "compressed=$compressed deleted=$deleted size: ${before}K -> ${after}K"
}

main "$@"
