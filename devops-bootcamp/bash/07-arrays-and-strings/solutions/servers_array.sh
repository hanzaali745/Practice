#!/usr/bin/env bash
# Lab 1 — indexed array basics
servers=("web-01" "web-02" "db-01" "cache-01" "lb-01")

echo "Count: ${#servers[@]}  First: ${servers[0]}  Last: ${servers[-1]}"
for i in "${!servers[@]}"; do
    echo "  $(( i + 1 )). ${servers[$i]}"
done

servers+=("web-03" "db-02")
unset 'servers[1]'
servers=("${servers[@]}")   # re-index

echo "After changes (${#servers[@]}):"
for i in "${!servers[@]}"; do
    echo "  $(( i + 1 )). ${servers[$i]}"
done
