#!/bin/sh
# Lab 2 — always clean up.
# Try:  sh lab2_trap.sh          (success)
#       sh lab2_trap.sh fail     (error → cleanup still runs)
#       sh lab2_trap.sh slow     (press Ctrl+C during the sleep → cleanup still runs)
set -eu

tmpdir=$(mktemp -d)

cleanup() {
    status=$?
    rm -rf "$tmpdir"
    echo "cleanup: removed $tmpdir (exit status $status)" >&2
}
trap cleanup EXIT
trap 'echo "Interrupted" >&2; exit 130' INT
trap 'exit 143' TERM

echo "Working in $tmpdir"
cp /etc/hosts /etc/passwd "$tmpdir/"
ls "$tmpdir"

case "${1:-}" in
    fail) echo "simulating a failure..."; false ;;
    slow) sleep 30 ;;
esac
echo "Finished OK"
