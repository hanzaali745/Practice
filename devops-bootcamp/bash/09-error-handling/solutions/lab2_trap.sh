#!/usr/bin/env bash
# Lab 2 — always clean up; report failing line numbers.
# Try:  ./lab2_trap.sh          (success)
#       ./lab2_trap.sh fail     (error → cleanup still runs)
#       ./lab2_trap.sh slow     (press Ctrl+C during sleep → cleanup still runs)
set -euo pipefail

tmpdir=$(mktemp -d)

cleanup() {
    local status=$?
    rm -rf "$tmpdir"
    echo "cleanup: removed $tmpdir (exit status $status)" >&2
}
trap cleanup EXIT
trap 'echo "ERROR: line $LINENO: \"$BASH_COMMAND\" exited with $?" >&2' ERR
trap 'echo "Interrupted by user" >&2; exit 130' INT

echo "Working in $tmpdir"
cp /etc/hosts /etc/passwd "$tmpdir/"
ls "$tmpdir"

case "${1:-}" in
    fail) false ;;
    slow) sleep 30 ;;
esac
echo "Finished OK"
