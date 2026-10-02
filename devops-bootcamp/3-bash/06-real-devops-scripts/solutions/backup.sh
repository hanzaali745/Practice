#!/usr/bin/env bash
#
# backup.sh — timestamped tar.gz backups with checksum and retention
# Usage: backup.sh [-n] [-k KEEP] SOURCE DEST
#   -n       dry run (show what would happen)
#   -k KEEP  number of backups to keep (default 7)
#
set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
DRY_RUN=false
KEEP=7

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$SCRIPT_NAME" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
run() { if $DRY_RUN; then log "[dry-run] $*"; else "$@"; fi; }
usage() { sed -n '3,7p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

main() {
    local opt
    while getopts ":nk:h" opt; do
        case "$opt" in
            n) DRY_RUN=true ;;
            k) KEEP="$OPTARG" ;;
            h) usage ;;
            *) usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    [[ $# -eq 2 ]] || usage
    [[ $KEEP =~ ^[1-9][0-9]*$ ]] || die "KEEP must be a positive integer"

    local source dest name stamp archive
    source="$(realpath "$1" 2>/dev/null)" || die "source not found: $1"
    [[ -e $source ]] || die "source not found: $1"
    dest="$2"
    name="$(basename "$source")"
    stamp="$(date +%Y%m%d-%H%M%S)"
    archive="$dest/${name}-${stamp}.tar.gz"

    run mkdir -p "$dest"
    log "backing up $source -> $archive"
    run tar -czf "$archive" -C "$(dirname "$source")" "$name"

    if ! $DRY_RUN; then
        (cd "$dest" && sha256sum "${archive##*/}" > "${archive##*/}.sha256" \
                    && sha256sum --quiet -c "${archive##*/}.sha256") || die "checksum verification failed"
        log "created $(du -h "$archive" | cut -f1) archive, checksum verified"
    fi

    # Retention: list newest first, delete everything after KEEP
    local old
    while IFS= read -r old; do
        log "removing old backup $old"
        run rm -f "$old" "$old.sha256"
    done < <(find "$dest" -maxdepth 1 -name "${name}-*.tar.gz" -printf '%T@ %p\n' 2>/dev/null \
             | sort -rn | tail -n +"$(( KEEP + 1 ))" | cut -d' ' -f2-)
}

main "$@"
