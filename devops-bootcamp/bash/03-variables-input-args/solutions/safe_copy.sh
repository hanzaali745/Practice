#!/usr/bin/env bash
# Lab 5 — copy a file to backup/, safe for names with spaces
# Setup:  touch "a file.txt" b.txt "c d e.txt"
# Try:    for f in *.txt; do ./safe_copy.sh "$f"; done
set -euo pipefail

src="${1:?Usage: $0 <file>}"
mkdir -p backup
cp -v -- "$src" "backup/"
# Without quotes, `cp $src backup/` with src="a file.txt" becomes `cp a file.txt backup/` → fails
