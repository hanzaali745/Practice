#!/usr/bin/env bash
#
# getopts_demo.sh — Lab 1: short-option parsing with validation
# Usage: getopts_demo.sh [-e ENV] [-r N] [-n] [-v] [-h] APP
#
set -euo pipefail

usage() {
    cat >&2 <<EOF
Usage: ${0##*/} [-e ENV] [-r N] [-n] [-v] [-h] APP
  -e ENV   dev | staging | prod (default: dev)
  -r N     replicas, positive integer (default: 1)
  -n       dry run
  -v       verbose
  -h       show this help
EOF
    exit 2
}

main() {
    local env="dev" replicas=1 dry_run=false verbose=false opt
    while getopts ":e:r:nvh" opt; do
        case "$opt" in
            e) env="$OPTARG" ;;
            r) replicas="$OPTARG" ;;
            n) dry_run=true ;;
            v) verbose=true ;;
            h) usage ;;
            :) echo "Option -$OPTARG requires a value" >&2; usage ;;
            \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    [[ $# -eq 1 ]] || { echo "Exactly one APP is required" >&2; usage; }
    [[ $env =~ ^(dev|staging|prod)$ ]] || { echo "Invalid env: $env" >&2; usage; }
    [[ $replicas =~ ^[1-9][0-9]*$ ]] || { echo "Replicas must be a positive integer" >&2; usage; }

    $verbose && echo "[verbose] parsed: env=$env replicas=$replicas dry_run=$dry_run app=$1" >&2
    echo "Plan: deploy '$1' to $env with $replicas replica(s)$($dry_run && echo ' [DRY RUN]')"
}

main "$@"
