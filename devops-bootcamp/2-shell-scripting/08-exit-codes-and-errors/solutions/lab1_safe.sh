#!/bin/sh
# Lab 1 — the same logic, done safely.
set -eu

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"
touch keep-me.txt

release_dir="./releases/old"
if [ -d "$release_dir" ]; then
    cd "$release_dir"
    echo "cleaning $release_dir"
else
    echo "Nothing to clean: $release_dir does not exist" >&2
fi

echo "Using ${OPTIONAL_VAR:-<default>}"   # an explicit default instead of a silent empty value

# No pipefail in sh: run the important command on its own and check it
if ! grep "x" /nope > matches.txt 2> /dev/null; then
    echo "grep failed (or found nothing) — handled explicitly" >&2
fi
sort matches.txt
echo "Done"
