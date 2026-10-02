# shellcheck shell=bash
# opsctl logs-report — summarise a combined-format access log.

cmd_logs_report() {
    local log="${1:-}"
    [[ -n $log ]] || die "usage: opsctl logs-report ACCESS_LOG"
    [[ -r $log ]] || die "cannot read $log"

    echo "== Requests =="
    wc -l < "$log"

    echo "== Top 5 IPs =="
    awk '{print $1}' "$log" | sort | uniq -c | sort -nr | head -5

    echo "== Status codes =="
    awk '{print $9}' "$log" | sort | uniq -c | sort -nr

    echo "== Top 5 paths =="
    awk '{print $7}' "$log" | sort | uniq -c | sort -nr | head -5

    echo "== Error rate =="
    awk '{t++; if ($9 >= 500) s++; else if ($9 >= 400) c++}
         END {printf "4xx: %d  5xx: %d  of %d (%.1f%% errors)\n", c, s, t, (c + s) / t * 100}' "$log"
}
