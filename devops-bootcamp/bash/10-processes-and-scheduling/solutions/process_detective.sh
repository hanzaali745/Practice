#!/usr/bin/env bash
# Lab 1 — process detective
echo "== Top 5 by CPU =="
ps aux --sort=-%cpu | head -n 6
echo "== Top 5 by memory =="
ps aux --sort=-%mem | head -n 6
echo "== This shell =="
echo "PID=$$ PPID=$PPID ($(ps -o comm= -p "$PPID"))"
echo "== Listening on port 22 =="
ss -tlnp 2>/dev/null | awk 'NR == 1 || $4 ~ /:22$/' || echo "ss not available"
