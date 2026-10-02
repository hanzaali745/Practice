#!/usr/bin/env bash
# Lab 4 — run a command on many hosts in parallel and summarise
# Usage: ./fleet.sh [-p PARALLEL] [-t TIMEOUT] HOSTS_FILE 'COMMAND'
set -uo pipefail

usage() { echo "Usage: $0 [-p PARALLEL] [-t TIMEOUT] HOSTS_FILE 'COMMAND'" >&2; exit 2; }

parallel=5
timeout_s=5
while getopts ":p:t:" opt; do
    case "$opt" in
        p) parallel="$OPTARG" ;;
        t) timeout_s="$OPTARG" ;;
        *) usage ;;
    esac
done
shift $(( OPTIND - 1 ))
(( $# == 2 )) || usage
[[ -r $1 ]] || { echo "ERROR: cannot read $1" >&2; exit 1; }

hosts_file="$1"
command="$2"
mapfile -t hosts < <(grep -vE '^[[:space:]]*(#|$)' "$hosts_file")
(( ${#hosts[@]} > 0 )) || { echo "ERROR: no hosts in $hosts_file" >&2; exit 1; }

outdir=$(mktemp -d)
trap 'rm -rf "$outdir"' EXIT

run_one() {
    local host="$1"
    ssh -n -o BatchMode=yes -o ConnectTimeout="$timeout_s" "$host" "$command" \
        > "$outdir/$host.out" 2>&1
    echo $? > "$outdir/$host.rc"
}

running=0
for host in "${hosts[@]}"; do
    run_one "$host" &
    (( ++running ))
    if (( running >= parallel )); then
        wait -n               # wait for ANY one job to finish (Bash 4.3+)
        (( running-- ))
    fi
done
wait

failed=0
printf '%-16s %-7s %s\n' "HOST" "STATUS" "OUTPUT"
for host in "${hosts[@]}"; do
    rc=$(cat "$outdir/$host.rc")
    first_line=$(head -n 1 "$outdir/$host.out")
    if [[ $rc == 0 ]]; then status="OK"; else status="FAIL($rc)"; (( ++failed )); fi
    printf '%-16s %-7s %s\n' "$host" "$status" "$first_line"
done

echo "---"
echo "$(( ${#hosts[@]} - failed ))/${#hosts[@]} hosts OK"
(( failed == 0 ))
