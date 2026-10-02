#!/usr/bin/env bash
# Lab 5 — compare dotted version numbers numerically
# Usage: ./vercmp.sh 1.10.2 1.9.15
set -euo pipefail

a="${1:?Usage: $0 A B}"
b="${2:?Usage: $0 A B}"

for v in "$a" "$b"; do
    [[ $v =~ ^[0-9]+(\.[0-9]+)*$ ]] || { echo "Not a version: $v" >&2; exit 2; }
done

IFS=. read -r -a pa <<< "$a"
IFS=. read -r -a pb <<< "$b"

for (( i = 0; i < ${#pa[@]} || i < ${#pb[@]}; i++ )); do
    x="${pa[i]:-0}"         # missing parts count as 0 (1.2 == 1.2.0)
    y="${pb[i]:-0}"
    if (( 10#$x > 10#$y )); then echo "$a > $b"; exit 0; fi
    if (( 10#$x < 10#$y )); then echo "$a < $b"; exit 0; fi
done
echo "$a = $b"
