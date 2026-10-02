#!/usr/bin/env bash
# Lab 3 — use the logging library from anywhere
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

log "Starting demo"
ok "Library loaded from $SCRIPT_DIR/lib"
warn "This is a warning"
error "This is an error (but we keep going)"
[[ -d /definitely/not/here ]] || die "Required directory missing — exiting"
