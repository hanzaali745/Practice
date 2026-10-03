#!/usr/bin/env bash
# add_target.sh NAME HOST:PORT [ROLE] — register a target through file service discovery (no reload needed)
#   ./add_target.sh prom-self localhost:9090 monitoring
set -euo pipefail
name=${1:?usage: add_target.sh NAME HOST:PORT [ROLE]}
target=${2:?usage: add_target.sh NAME HOST:PORT [ROLE]}
role=${3:-misc}
[[ $name =~ ^[a-z0-9-]+$ ]] || { echo "NAME: lowercase letters, digits and dashes only" >&2; exit 2; }
cd "$(dirname "$0")"
tmp=$(mktemp targets/.tmp.XXXXXX)
printf '[{"targets": ["%s"], "labels": {"role": "%s"}}]\n' "$target" "$role" > "$tmp"
chmod 644 "$tmp"                          # Prometheus runs as user "nobody": it must be able to read it
mv "$tmp" "targets/$name.json"            # write-then-rename: Prometheus never reads a half-written file
echo "added targets/$name.json — Prometheus picks it up within 30 s"
