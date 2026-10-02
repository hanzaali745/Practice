#!/usr/bin/env bash
# Lab 2 — arguments inspector
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <arg> [arg...]" >&2
    exit 1
fi

echo "Script: $0"
echo "Count:  $#"
n=1
for arg in "$@"; do
    echo "  $n: $arg"
    n=$(( n + 1 ))
done
