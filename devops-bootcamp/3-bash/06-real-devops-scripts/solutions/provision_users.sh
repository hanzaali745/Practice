#!/usr/bin/env bash
#
# provision_users.sh — create groups/users from a CSV, idempotently
# Usage: provision_users.sh [--apply] USERS_CSV
#   Without --apply it only prints what it WOULD do (safe default).
#   CSV columns: username,group,shell
#
set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
APPLY=false

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$SCRIPT_NAME" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
run() { if $APPLY; then "$@"; else log "[dry-run] $*"; fi; }
usage() { sed -n '3,6p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

main() {
    [[ ${1:-} == "--apply" ]] && { APPLY=true; shift; }
    [[ $# -eq 1 && -r $1 ]] || usage
    if $APPLY && [[ $EUID -ne 0 ]]; then
        die "--apply must be run as root"
    fi

    local username group shell current_shell
    local -A planned_groups=()   # so a dry run doesn't "create" the same group twice
    while IFS=, read -r username group shell; do
        [[ -z $username || $username == "username" || $username == \#* ]] && continue
        [[ $username =~ ^[a-z_][a-z0-9_-]*$ ]] || { log "skipping invalid username '$username'"; continue; }
        [[ -x $shell ]] || { log "WARN: shell $shell not installed, using /bin/bash for $username"; shell=/bin/bash; }

        if getent group "$group" > /dev/null || [[ -v planned_groups[$group] ]]; then
            log "group $group exists"
        else
            run groupadd "$group"
            planned_groups[$group]=1
        fi

        if id "$username" &> /dev/null; then
            current_shell=$(getent passwd "$username" | cut -d: -f7)
            if [[ $current_shell != "$shell" ]]; then
                run usermod -s "$shell" "$username"
            else
                log "user $username already up to date"
            fi
            run usermod -aG "$group" "$username"
        else
            run useradd -m -s "$shell" -G "$group" "$username"
        fi
    done < "$1"
    $APPLY || log "dry run complete — re-run with --apply to make changes"
}

main "$@"
