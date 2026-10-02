#!/usr/bin/env bash
# Lab 2 — collect facts from a remote host over ONE ssh connection
# Usage: ./remote_facts.sh HOST
set -euo pipefail

host="${1:?Usage: $0 HOST}"

# The quoted 'REMOTE' heredoc is sent as-is: every $ below expands on the REMOTE server.
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" 'bash -s' <<'REMOTE'
. /etc/os-release
echo "hostname=$(hostname)"
echo "os=$PRETTY_NAME"
echo "kernel=$(uname -r)"
echo "uptime=$(uptime -p)"
echo "disk_root=$(df -P / | awk 'NR == 2 {print $5}')"
echo "memory=$(free -m | awk '/^Mem:/ {printf "%d/%d MB", $3, $2}')"
REMOTE
then
    echo "ERROR: could not collect facts from $host" >&2
    exit 1
fi
