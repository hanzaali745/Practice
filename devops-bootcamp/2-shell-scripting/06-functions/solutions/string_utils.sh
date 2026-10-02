#!/bin/sh
# Lab 1 — string helper functions (POSIX)

to_upper() { printf '%s\n' "$1" | tr '[:lower:]' '[:upper:]'; }
to_lower() { printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'; }
trim()     { printf '%s\n' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }

repeat() (
    count=0
    out=""
    while [ "$count" -lt "$2" ]; do
        out="$out$1"
        count=$((count + 1))
    done
    printf '%s\n' "$out"
)

to_upper "web-01"
to_lower "PROD"
echo "[$(trim "   hello devops   ")]"
repeat "=" 20
