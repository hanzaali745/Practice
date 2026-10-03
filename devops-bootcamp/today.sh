#!/bin/sh
#
# today.sh — your daily study companion for the bootcamp
# Usage:
#   sh today.sh            show today's task
#   sh today.sh done       mark today complete and show tomorrow's task
#   sh today.sh status     progress summary
#   sh today.sh day N      show any day's task (doesn't change progress)
#   sh today.sh back       go back one day (if you marked "done" by mistake)
#   sh today.sh list       one line per day
#
# Progress is saved in my-work/progress.log — commit it with your lab work.
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
PLAN="$HERE/DAILY-PLAN.md"
LOG="$HERE/my-work/progress.log"

die() { echo "ERROR: $*" >&2; exit 1; }
[ -r "$PLAN" ] || die "cannot find $PLAN"

total_days() { grep -c '^## Day [0-9]* ' "$PLAN"; }

# Today's day = (number of days marked done) + 1
done_count() {
    # grep -c prints 0 but EXITS 1 when nothing matches — "|| true" stops set -e from killing us
    if [ -f "$LOG" ]; then grep -c '^done ' "$LOG" || true; else echo 0; fi
}

show_day() {
    # Print the "## Day N — ..." section up to (not including) the next "## " heading
    awk -v n="$1" '
        $0 ~ "^## Day " n " " { found = 1; print; next }
        found && /^## /       { exit }
        found && /^---$/      { exit }
        found                 { print }
        END { if (!found) exit 1 }
    ' "$PLAN" || die "there is no Day $1 (plan has $(total_days) days)"
}

progress_bar() {
    # progress_bar DONE TOTAL → [#######.............] 35%
    awk -v d="$1" -v t="$2" 'BEGIN {
        w = 30; f = int(d * w / t); bar = ""
        for (i = 0; i < w; i++) bar = bar (i < f ? "#" : ".")
        printf "[%s] %d%% (%d/%d days)\n", bar, d * 100 / t, d, t
    }'
}

planned_reminder() {
    # From the first day of Phase 8 on, remind about PLANNED-ADDITIONS.md until nothing in it is PLANNED.
    # The start of Phase 8 is found in the plan (its "Setup part 3" day), so it stays right if days move.
    notes="$HERE/PLANNED-ADDITIONS.md"
    [ -f "$notes" ] && grep -q '^Status: PLANNED' "$notes" || return 0
    phase8=$(sed -n 's/^## Day \([0-9]*\) — Setup part 3 .*/\1/p' "$PLAN" | head -n 1)
    [ -n "$phase8" ] && [ "$1" -ge "$phase8" ] || return 0
    echo
    echo "📌 Reminder: you've reached Phase 8 — time to add the planned Phase 13 platform skills"
    echo "   (databases, secrets management, OpenTelemetry + Grafana). See PLANNED-ADDITIONS.md,"
    echo "   then ask Claude: \"let's add the Phase 13 platform skills\"."
}

cmd="${1:-today}"
total=$(total_days)
completed=$(done_count)
today=$((completed + 1))

case "$cmd" in
    today|"")
        if [ "$today" -gt "$total" ]; then
            echo "🎉 You've completed all $total days. Congratulations, engineer!"
            exit 0
        fi
        printf '📅 Today is Day %s of %s   ' "$today" "$total"
        progress_bar "$completed" "$total"
        echo
        show_day "$today"
        echo "When you're finished:  sh today.sh done"
        planned_reminder "$today"
        ;;
    done)
        [ "$today" -le "$total" ] || { echo "All $total days are already done 🎉"; exit 0; }
        mkdir -p "$(dirname "$LOG")"
        printf 'done %s %s\n' "$today" "$(date '+%Y-%m-%d %H:%M')" >> "$LOG"
        echo "✅ Day $today complete! Great work."
        progress_bar "$today" "$total"
        if [ "$today" -lt "$total" ]; then
            echo
            echo "Tomorrow (Day $((today + 1))):"
            show_day "$((today + 1))" | head -n 1
        fi
        echo
        echo "Don't forget:  git add -A && git commit -m \"Day $today\" && git push"
        planned_reminder "$((today + 1))"
        ;;
    status)
        progress_bar "$completed" "$total"
        if [ -f "$LOG" ] && [ "$completed" -gt 0 ]; then
            first=$(awk '/^done /{print $3; exit}' "$LOG")
            last=$(awk '/^done /{d=$3} END{print d}' "$LOG")
            active=$(awk '/^done /{print $3}' "$LOG" | sort -u | wc -l)
            echo "Started: $first   Last study day: $last   Days you studied: $active"
        fi
        echo "Next: $(show_day "$today" 2> /dev/null | head -n 1 | sed 's/^## //' || echo 'all done 🎉')"
        ;;
    day)
        n="${2:-}"
        case "$n" in
            ''|*[!0-9]*) die "usage: sh today.sh day N" ;;
        esac
        show_day "$n"
        ;;
    back)
        [ "$completed" -gt 0 ] || die "nothing to undo"
        tmp=$(mktemp)
        trap 'rm -f "$tmp"' EXIT
        # remove the LAST "done" line, keep everything else
        awk -v last="$completed" '/^done /{c++; if (c == last) next} {print}' "$LOG" > "$tmp"
        cat "$tmp" > "$LOG"
        echo "↩️  Day $completed marked as not done. Today is Day $completed again."
        ;;
    list)
        grep '^## Day [0-9]* ' "$PLAN" | sed 's/^## //' | awk -v t="$today" '{
            n = $2; mark = (n < t) ? "✅" : (n == t ? "👉" : "  ")
            print mark " " $0
        }'
        ;;
    -h|--help|help)
        sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//' >&2
        exit 2
        ;;
esac
