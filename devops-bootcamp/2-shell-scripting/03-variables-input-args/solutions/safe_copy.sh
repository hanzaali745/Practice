#!/bin/sh
# Lab 5 — copy a file into backup/, safe for names with spaces
# Setup:  touch "a file.txt" b.txt "c d e.txt"
# Try:    for f in *.txt; do sh safe_copy.sh "$f"; done
set -eu

src="${1:?Usage: $0 <file>}"
mkdir -p backup
cp -- "$src" backup/
echo "copied '$src' -> backup/"
# Without quotes, cp $src backup/ with src="a file.txt" becomes: cp a file.txt backup/  → error
