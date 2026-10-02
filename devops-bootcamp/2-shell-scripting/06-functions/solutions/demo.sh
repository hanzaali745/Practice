#!/bin/sh
# Lab 3 — use the logging library from any folder
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib/logging.sh
. "$SCRIPT_DIR/lib/logging.sh"

log "Starting demo"
ok "Library loaded from $SCRIPT_DIR/lib"
warn "This is a warning"
error "This is an error (but we keep going)"
[ -d /definitely/not/here ] || die "Required directory missing — exiting"
