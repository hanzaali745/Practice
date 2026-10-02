#!/bin/sh
# Lab 1 — build numbers
i=1
while [ "$i" -le 10 ]; do
    if [ $((i % 5)) -eq 0 ]; then
        echo "Build #$i (release)"
    else
        echo "Build #$i"
    fi
    i=$((i + 1))
done
