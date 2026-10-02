#!/usr/bin/env bash
#
# longopts_demo.sh — Lab 2: short AND long options with a while/case loop
# Usage: longopts_demo.sh [--env ENV] [--replicas N] [--dry-run] [--verbose] [--] APP
#
set -euo pipefail

usage() {
    cat >&2 <<EOF
Usage: ${0##*/} [options] [--] APP
  -e, --env ENV        dev | staging | prod (default: dev)
  -r, --replicas N     positive integer (default: 1)
  -n, --dry-run        dry run
  -v, --verbose        verbose
  -h, --help           show this help
EOF
    exit 2
}

main() {
    local env="dev" replicas=1 dry_run=false verbose=false
    local -a args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--env)       [[ $# -ge 2 ]] || usage; env="$2"; shift 2 ;;
            --env=*)        env="${1#*=}"; shift ;;
            -r|--replicas)  [[ $# -ge 2 ]] || usage; replicas="$2"; shift 2 ;;
            --replicas=*)   replicas="${1#*=}"; shift ;;
            -n|--dry-run)   dry_run=true; shift ;;
            -v|--verbose)   verbose=true; shift ;;
            -h|--help)      usage ;;
            --)             shift; args+=("$@"); break ;;
            -*)             echo "Unknown option: $1" >&2; usage ;;
            *)              args+=("$1"); shift ;;
        esac
    done

    [[ ${#args[@]} -eq 1 ]] || { echo "Exactly one APP is required" >&2; usage; }
    [[ $env =~ ^(dev|staging|prod)$ ]] || { echo "Invalid env: $env" >&2; usage; }
    [[ $replicas =~ ^[1-9][0-9]*$ ]] || { echo "Replicas must be a positive integer" >&2; usage; }

    $verbose && echo "[verbose] env=$env replicas=$replicas dry_run=$dry_run" >&2
    echo "Plan: deploy '${args[0]}' to $env with $replicas replica(s)$($dry_run && echo ' [DRY RUN]')"
}

main "$@"
