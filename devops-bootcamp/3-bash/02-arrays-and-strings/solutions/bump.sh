#!/usr/bin/env bash
# Lab 4 — semantic version bumper
# Usage: ./bump.sh <X.Y.Z> <major|minor|patch>
set -euo pipefail

version="${1:-}"
part="${2:-}"

if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Usage: $0 <X.Y.Z> <major|minor|patch>" >&2
    exit 1
fi

IFS=. read -r major minor patch <<< "$version"

case "$part" in
    major) echo "$(( major + 1 )).0.0" ;;
    minor) echo "${major}.$(( minor + 1 )).0" ;;
    patch) echo "${major}.${minor}.$(( patch + 1 ))" ;;
    *) echo "Part must be major, minor or patch" >&2; exit 1 ;;
esac
