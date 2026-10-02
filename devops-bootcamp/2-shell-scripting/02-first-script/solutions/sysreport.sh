#!/bin/sh
# Lab 2 — simple system report (POSIX sh)
set -eu

os=$(uname -s)
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    os=$(. /etc/os-release && printf '%s' "$PRETTY_NAME")
fi
up=$(uptime -p 2>/dev/null || uptime)
disk=$(df -h / | awk 'NR == 2 {print $3 " used of " $2 " (" $5 ")"}')
mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " used of " $2}')
ip=$(hostname -I 2>/dev/null | awk '{print $1}')

printf '%-10s %s\n' "Hostname:" "$(hostname)"
printf '%-10s %s\n' "OS:" "$os"
printf '%-10s %s\n' "Kernel:" "$(uname -r)"
printf '%-10s %s\n' "Uptime:" "$up"
printf '%-10s %s\n' "Disk /:" "$disk"
printf '%-10s %s\n' "Memory:" "${mem:-n/a}"
printf '%-10s %s\n' "IP:" "${ip:-n/a}"
