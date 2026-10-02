#!/bin/sh
# Module 07 lab solutions. Run from anywhere: sh labs.sh
# Tip: run each command yourself in the terminal — that's how you build the muscle memory.
set -eu

DATA="$(cd "$(dirname "$0")/../data" && pwd)"
APP_LOG="$DATA/app.log"
CONF="$DATA/app.conf"
ACCESS="$DATA/access.log"

section() { printf '\n===== %s =====\n' "$*"; }

section "Lab 1.1 ERROR lines"
grep "ERROR" "$APP_LOG"

section "Lab 1.2 ERROR + CRITICAL count"
grep -cE " (ERROR|CRITICAL) " "$APP_LOG"

section "Lab 1.3 lines that are NOT INFO"
grep -v " INFO " "$APP_LOG"

section "Lab 1.4 db-01 lines with numbers"
grep -n "db-01" "$APP_LOG"

section "Lab 2.1 config without comments/blank lines"
grep -vE '^\s*(#|$)' "$CONF"

section "Lab 2.2 keys only"
grep -vE '^\s*(#|$)' "$CONF" | cut -d= -f1

section "Lab 2.3 value of DB_PORT"
awk -F= '$1 == "DB_PORT" {print $2}' "$CONF"

section "Lab 2.4 masked password"
sed -E 's/^(DB_PASSWORD=).*/\1******/' "$CONF"

section "Lab 3 sed edits on a copy"
tmp="$(mktemp)"
cp "$CONF" "$tmp"
sed -i -e 's/^APP_ENV=.*/APP_ENV=production/' \
       -e 's/^LOG_LEVEL=.*/LOG_LEVEL=info/' \
       -e 's/^# *\(FEATURE_X=.*\)/\1/' \
       -e 's/^LISTEN_PORT=.*/LISTEN_PORT=9090/' "$tmp"
diff "$CONF" "$tmp" || true    # diff exits 1 when files differ — that's expected
rm -f "$tmp"

section "Lab 4.1 total requests"
wc -l < "$ACCESS"

section "Lab 4.2 top 3 IPs"
cut -d' ' -f1 "$ACCESS" | sort | uniq -c | sort -nr | head -3

section "Lab 4.3 requests per status"
awk '{print $9}' "$ACCESS" | sort | uniq -c | sort -nr

section "Lab 4.4 5xx lines"
awk '$9 >= 500' "$ACCESS"

section "Lab 4.5 total bytes"
awk '{sum += $10} END {print sum " bytes"}' "$ACCESS"

section "Lab 4.6 most requested path"
awk '{print $7}' "$ACCESS" | sort | uniq -c | sort -nr | head -1

section "Lab 4.7 requests per minute"
# [01/May/2024:10:00:01 → take characters up to the minute
awk '{print substr($4, 2, 17)}' "$ACCESS" | sort | uniq -c
