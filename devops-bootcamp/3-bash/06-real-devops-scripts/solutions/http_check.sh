#!/usr/bin/env bash
#
# http_check.sh — check URLs in parallel, report, optionally alert Slack
# Usage: http_check.sh [-t TIMEOUT] URL_FILE
#   Set SLACK_WEBHOOK_URL to post failures to Slack.
#
set -uo pipefail

TIMEOUT=5

usage() { sed -n '3,5p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

check_url() {
    local url="$1" result code time
    result=$(curl -s -o /dev/null -w '%{http_code} %{time_total}' --max-time "$TIMEOUT" "$url")
    read -r code time <<< "$result"
    if [[ $code =~ ^[23] ]]; then
        printf 'UP    %-40s %s %6.3fs\n' "$url" "$code" "$time"
    else
        printf 'DOWN  %-40s %s %6.3fs\n' "$url" "$code" "$time"
        return 1
    fi
}

notify() {
    [[ -n ${SLACK_WEBHOOK_URL:-} ]] || return 0
    local text="$1"
    curl -s -X POST -H 'Content-Type: application/json' \
         --data "{\"text\": \"${text//\"/\\\"}\"}" "$SLACK_WEBHOOK_URL" > /dev/null
}

main() {
    while getopts ":t:h" opt; do
        case "$opt" in
            t) TIMEOUT="$OPTARG" ;;
            *) usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    [[ $# -eq 1 && -r $1 ]] || usage

    local outdir url
    outdir=$(mktemp -d)
    trap 'rm -rf "$outdir"' EXIT

    local i=0
    while IFS= read -r url; do
        [[ -z $url || $url == \#* ]] && continue
        i=$(( i + 1 ))
        ( check_url "$url" > "$outdir/$i.out"; echo $? > "$outdir/$i.rc" ) &
    done < "$1"
    wait

    local down=0 n
    for (( n = 1; n <= i; n++ )); do
        cat "$outdir/$n.out"
        [[ $(cat "$outdir/$n.rc") == 0 ]] || down=$(( down + 1 ))
    done

    echo "---"
    echo "$(( i - down ))/$i up"
    if (( down > 0 )); then
        notify ":rotating_light: $down of $i URLs are DOWN on $(hostname)"
        exit 1
    fi
}

main "$@"
