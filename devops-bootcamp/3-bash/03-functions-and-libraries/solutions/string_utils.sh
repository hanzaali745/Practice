#!/usr/bin/env bash
# Lab 1 — string utility functions

to_upper() { echo "${1^^}"; }
to_lower() { echo "${1,,}"; }

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"   # remove leading whitespace
    s="${s%"${s##*[![:space:]]}"}"   # remove trailing whitespace
    echo "$s"
}

repeat() {
    local char="$1" n="$2" out=""
    local i
    for (( i = 0; i < n; i++ )); do out+="$char"; done
    echo "$out"
}

to_upper "web-01"
to_lower "PROD"
echo "[$(trim "   hello devops   ")]"
repeat "=" 20
