#!/usr/bin/env bash
# Lab 1 — print a server banner
cat <<EOF
==========================================
 Host:   $(hostname)
 User:   $(whoami)
 Date:   $(date '+%Y-%m-%d %H:%M:%S')
 Uptime: $(uptime -p 2>/dev/null || uptime)
==========================================
EOF
