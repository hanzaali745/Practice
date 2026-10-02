#!/usr/bin/env bash
# Lab 1 — the same logic, done safely.
set -euo pipefail

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"
touch keep-me.txt

release_dir="./releases/old"
if [[ -d $release_dir ]]; then
    cd "$release_dir"
    echo "cleaning $release_dir"
else
    echo "Nothing to clean: $release_dir does not exist" >&2
fi

echo "Using ${OPTIONAL_VAR:-<default>}"   # explicit default instead of a silent empty value

if ! grep "x" /nope 2>/dev/null | sort; then
    echo "grep failed and pipefail reported it" >&2
fi
echo "Done"
