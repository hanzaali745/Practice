#!/usr/bin/env bash
#
# deploy.sh — release-folder deploys with health check and rollback
# Usage: deploy.sh deploy SRC_DIR | rollback | list
#   APP_ROOT (default /tmp/myapp) holds releases/ and the current symlink.
#   If a release contains an executable healthcheck.sh it must pass before switching.
#
set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
APP_ROOT="${APP_ROOT:-/tmp/myapp}"
RELEASES="$APP_ROOT/releases"
CURRENT="$APP_ROOT/current"
KEEP="${KEEP:-5}"

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$SCRIPT_NAME" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
usage() { sed -n '3,6p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

current_release() { [[ -L $CURRENT ]] && basename "$(readlink "$CURRENT")" || true; }
sorted_releases() { find "$RELEASES" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort; }

switch_to() {
    ln -sfn "$RELEASES/$1" "$CURRENT.tmp"
    mv -Tf "$CURRENT.tmp" "$CURRENT"      # rename is atomic: no moment without a 'current'
    log "current -> $1"
}

health_check() {
    local dir="$1"
    if [[ -x $dir/healthcheck.sh ]]; then
        log "running health check"
        "$dir/healthcheck.sh"
    else
        log "no healthcheck.sh, skipping health check"
    fi
}

cleanup_old() {
    local old
    while IFS= read -r old; do
        [[ $old == "$(current_release)" ]] && continue
        log "removing old release $old"
        rm -rf "${RELEASES:?}/$old"
    done < <(sorted_releases | head -n -"$KEEP")
}

cmd_deploy() {
    local src="${1:-}"
    [[ -d $src ]] || die "source directory not found: ${src:-<none>}"
    local release
    release="$(date +%Y%m%d-%H%M%S)"
    [[ -e $RELEASES/$release ]] && release="${release}-$$"
    mkdir -p "$RELEASES"
    cp -a "$src" "$RELEASES/$release"
    log "copied $src -> releases/$release"

    if ! health_check "$RELEASES/$release"; then
        rm -rf "${RELEASES:?}/$release"
        die "health check failed; release discarded, still on $(current_release)"
    fi
    switch_to "$release"
    cleanup_old
}

cmd_rollback() {
    local current previous
    current="$(current_release)"
    [[ -n $current ]] || die "nothing deployed yet"
    previous="$(sorted_releases | grep -B1 -x "$current" | head -n 1)"
    [[ -n $previous && $previous != "$current" ]] || die "no previous release to roll back to"
    switch_to "$previous"
    log "rolled back from $current to $previous"
}

cmd_list() {
    local current r
    current="$(current_release)"
    while IFS= read -r r; do
        if [[ $r == "$current" ]]; then echo "* $r (current)"; else echo "  $r"; fi
    done < <(sorted_releases)
}

case "${1:-}" in
    deploy)   shift; cmd_deploy "$@" ;;
    rollback) cmd_rollback ;;
    list)     cmd_list ;;
    *)        usage ;;
esac
