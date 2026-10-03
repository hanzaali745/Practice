#!/usr/bin/env bash
# lab.sh — the troubleshooting lab: an Ubuntu server (systemd · nginx → demo-app → Redis) that breaks on demand.
#
#   ./lab.sh list                 the scenarios
#   ./lab.sh break NAME           fresh server, then break it (you get the alert, not the cause)
#   ./lab.sh shell                log in to the server as the on-call user (sudo works)
#   ./lab.sh hint                 the next hint for the current scenario (3 per scenario)
#   ./lab.sh check                is it fixed — properly?
#   ./lab.sh incident [--hard]    a RANDOM scenario (--hard: two at once), timed — like a real page
#   ./lab.sh status | reset | down
set -euo pipefail
cd "$(dirname "$0")"
state=.lab-state                       # current scenario, start time, hints used

die() { echo "❌ $*" >&2; exit 1; }
in_server() { docker compose exec -T server bash -s; }      # run stdin as root inside the server
scenario_dir() { [[ -d scenarios/$1 ]] || die "no scenario '$1' — see ./lab.sh list"; echo "scenarios/$1"; }
parts() {                               # a combined incident lists its parts in a "combo" file
    local dir
    dir=$(scenario_dir "$1")
    if [[ -f $dir/combo ]]; then cat "$dir/combo"; else echo "$1"; fi
}
get() { [[ -f $state ]] && grep -m1 "^$1=" "$state" | cut -d= -f2-; }
current() { get scenario || true; }

boot() {                                # a fresh server every time: no leftovers from the last scenario
    docker compose down --volumes --timeout 2 > /dev/null 2>&1 || true
    docker compose up -d > /dev/null 2>&1 || docker compose up -d   # builds the image the first time (a few minutes)
    local s
    for _ in $(seq 1 60); do
        s=$(docker compose exec -T server systemctl is-system-running 2>/dev/null || true)
        if [[ $s == running || $s == degraded ]] &&
           docker compose exec -T server curl -sf --max-time 2 http://localhost/visits > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    die "the server didn't come up healthy — try: docker compose logs"
}

do_break() {
    local name=$1 part
    echo "🔧 Starting a fresh server..."
    boot
    for part in $(parts "$name"); do
        in_server < "$(scenario_dir "$part")/break.sh" > /dev/null
    done
    printf 'scenario=%s\nstarted=%s\nhints=0\n' "$name" "$(date +%s)" > "$state"
}

story() { cat "$(scenario_dir "$1")/story.txt"; }

case ${1:-} in
    list)
        printf '%-20s %s\n' SCENARIO "THE ALERT YOU GET"
        for d in scenarios/*/; do
            n=$(basename "$d")
            [[ -f $d/story.txt ]] && printf '%-20s %s\n' "$n" "$(head -1 "$d/story.txt")"
        done ;;
    break)
        name=${2:?usage: lab.sh break NAME}
        scenario_dir "$name" > /dev/null
        do_break "$name"
        echo; story "$name"
        echo; echo "👉 ./lab.sh shell   to investigate · ./lab.sh hint   if stuck · ./lab.sh check   when fixed" ;;
    incident)
        mapfile -t pool < <(for d in scenarios/*/; do
            n=$(basename "$d")
            if [[ ${2:-} == --hard ]]; then [[ -f $d/combo ]] && echo "$n"; else [[ -f $d/break.sh ]] && echo "$n"; fi
        done)
        name=${pool[RANDOM % ${#pool[@]}]}
        do_break "$name"
        echo; echo "📟 PAGE — $(date '+%H:%M') — you are on call"; echo
        story "$name"; echo
        echo "⏱️  The clock is running. ./lab.sh check when you think it's fixed — then write the postmortem." ;;
    shell)
        exec docker compose exec -u oncall -w /home/oncall server bash -l ;;
    hint)
        name=$(current); [[ -n $name ]] || die "no scenario running — ./lab.sh break NAME first"
        used=$(get hints)
        n=$((used + 1))
        shown=0
        for part in $(parts "$name"); do
            text=$(awk -v n="$n" '/^## Hint /{h++} h==n' "$(scenario_dir "$part")/hints.md")
            [[ -n $text ]] && { echo "$text"; echo; shown=1; }
        done
        (( shown )) || die "no more hints — the walkthroughs are in the module's solutions/ folder"
        sed -i "s/^hints=.*/hints=$n/" "$state" ;;
    check)
        name=${2:-$(current)}; [[ -n $name ]] || die "no scenario running — ./lab.sh break NAME first"
        rc=0
        for part in $(parts "$name"); do
            echo "🔍 $part"
            cat scenarios/lib.sh "$(scenario_dir "$part")/check.sh" | in_server || rc=1
        done
        if (( rc == 0 )); then
            started=$(get started)
            if [[ -n $started ]]; then echo "✅ Fixed in $(( ($(date +%s) - started) / 60 )) min, with $(get hints) hint(s)."; else echo "✅ Fixed."; fi
            echo "📝 Now write it up: ../04-incident-practice/postmortem-template.md"
        else
            echo "❌ Not fixed yet (or only the symptom is gone). Keep going — ./lab.sh hint if you're stuck."
            exit 1
        fi ;;
    status)
        docker compose ps
        [[ -n $(current) ]] && echo "current scenario: $(current) (hints used: $(get hints))" || true ;;
    reset)
        boot; rm -f "$state"; echo "✅ fresh, healthy server" ;;
    down)
        docker compose down --volumes; rm -f "$state" ;;
    *)
        sed -n '2,11p' "$0"; exit 2 ;;
esac
