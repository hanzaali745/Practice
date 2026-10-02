#!/bin/sh
#
# docker-entrypoint.sh — validate env, wait for the DB, render config, then exec the app
# Usage: docker-entrypoint.sh <command> [args...]
#
# Environment:
#   APP_ENV       required  dev | staging | prod
#   DB_HOST       required  database host
#   DB_PORT       optional  default 5432
#   LOG_LEVEL     optional  default info
#   WAIT_TIMEOUT  optional  seconds to wait for the DB, default 30 (0 = don't wait)
#   TEMPLATE      optional  default ./app.conf.template
#   CONFIG_OUT    optional  default /tmp/app.conf
#
set -eu

log() { printf '%s [entrypoint] %s\n' "$(date '+%F %T')" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

require_env() {
    for var in "$@"; do
        eval "value=\${$var:-}"          # read the variable whose NAME is in $var
        # shellcheck disable=SC2154      # value is assigned by eval above
        [ -n "$value" ] || die "required environment variable $var is not set"
    done
}

validate() {
    require_env APP_ENV DB_HOST
    case "$APP_ENV" in
        dev|staging|prod) ;;
        *) die "APP_ENV must be dev, staging or prod (got '$APP_ENV')" ;;
    esac
    case "$DB_PORT" in
        ''|*[!0-9]*) die "DB_PORT must be a number (got '$DB_PORT')" ;;
    esac
}

wait_for_db() {
    [ "$WAIT_TIMEOUT" -eq 0 ] && { log "WAIT_TIMEOUT=0, not waiting for the database"; return 0; }
    command -v nc > /dev/null 2>&1 || die "nc (netcat) is required to wait for the database"
    waited=0
    until nc -z -w1 "$DB_HOST" "$DB_PORT" 2> /dev/null; do
        [ "$waited" -lt "$WAIT_TIMEOUT" ] || die "database $DB_HOST:$DB_PORT not reachable after ${WAIT_TIMEOUT}s"
        log "waiting for database $DB_HOST:$DB_PORT (${waited}s)"
        sleep 1
        waited=$((waited + 1))
    done
    log "database $DB_HOST:$DB_PORT is reachable"
}

render_config() {
    [ -f "$TEMPLATE" ] || die "template not found: $TEMPLATE"
    tmp="$CONFIG_OUT.tmp.$$"
    trap 'rm -f "$tmp"' EXIT
    # Replace ${VAR} placeholders. The | delimiter allows / in values (e.g. paths, URLs).
    sed -e "s|\${APP_ENV}|$APP_ENV|g" \
        -e "s|\${DB_HOST}|$DB_HOST|g" \
        -e "s|\${DB_PORT}|$DB_PORT|g" \
        -e "s|\${LOG_LEVEL}|$LOG_LEVEL|g" \
        "$TEMPLATE" > "$tmp"
    mv "$tmp" "$CONFIG_OUT"          # write to a temp file, then move: never a half-written config
    trap - EXIT
    log "rendered $TEMPLATE -> $CONFIG_OUT"
}

main() {
    [ $# -ge 1 ] || { echo "Usage: $0 <command> [args...]" >&2; exit 2; }

    DB_PORT="${DB_PORT:-5432}"
    LOG_LEVEL="${LOG_LEVEL:-info}"
    WAIT_TIMEOUT="${WAIT_TIMEOUT:-30}"
    TEMPLATE="${TEMPLATE:-$(dirname "$0")/app.conf.template}"
    CONFIG_OUT="${CONFIG_OUT:-/tmp/app.conf}"

    validate
    wait_for_db
    render_config

    log "starting: $*"
    exec "$@"      # replace this shell with the app → the app becomes PID 1 and gets signals directly
}

main "$@"
