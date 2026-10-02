#!/usr/bin/env bash
# Lab 2 — simple system report
set -euo pipefail

if [[ -r /etc/os-release ]]; then
    os=$(awk -F= '$1=="PRETTY_NAME" {gsub(/"/, "", $2); print $2}' /etc/os-release)
else
    os=$(uname -s)
fi
kernel=$(uname -r)
up=$(uptime -p 2>/dev/null || uptime)
disk=$(df -h / | awk 'NR==2 {print $3 " used of " $2 " (" $5 ")"}')
mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " used of " $2}' || true)
ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)

printf "%-12s %s\n" "Hostname:" "$(hostname)"
printf "%-12s %s\n" "OS:" "$os"
printf "%-12s %s\n" "Kernel:" "$kernel"
printf "%-12s %s\n" "Uptime:" "$up"
printf "%-12s %s\n" "Disk /:" "$disk"
printf "%-12s %s\n" "Memory:" "${mem:-n/a}"
printf "%-12s %s\n" "IP:" "${ip:-n/a}"
