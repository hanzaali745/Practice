#!/usr/bin/env bash
# nightly_job.sh — a cron-style batch job that reports its result through node-exporter's TEXTFILE collector.
# Batch jobs don't live long enough to be scraped, so they write a .prom file; node-exporter serves it.
#   ./nightly_job.sh            (or make it fail on purpose: FAIL=1 ./nightly_job.sh)
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
textfile_dir=${TEXTFILE_DIR:-$here/textfile}
start=$(date +%s)

# --- the actual work: here, "back up" the app folder into backups/ -------------------------
backup="$here/backups/app-$(date +%Y%m%d-%H%M%S).tar.gz"
if [[ ${FAIL:-0} == 1 ]]; then
    status=1
else
    tar -czf "$backup" -C "$here/../../../4-docker" app 2>/dev/null
    status=$?
fi
end=$(date +%s)
# ------------------------------------------------------------------------------------------

success=0; [[ $status -eq 0 ]] && success=1
tmp=$(mktemp "$textfile_dir/.nightly.XXXXXX")
{
    echo "# HELP nightly_job_last_run_timestamp_seconds When the nightly job last finished."
    echo "# TYPE nightly_job_last_run_timestamp_seconds gauge"
    echo "nightly_job_last_run_timestamp_seconds $end"
    echo "# HELP nightly_job_last_success Whether the last run succeeded (1) or failed (0)."
    echo "# TYPE nightly_job_last_success gauge"
    echo "nightly_job_last_success $success"
    echo "# HELP nightly_job_duration_seconds How long the last run took."
    echo "# TYPE nightly_job_duration_seconds gauge"
    echo "nightly_job_duration_seconds $((end - start))"
    if (( success )); then
        echo "# HELP nightly_job_last_success_timestamp_seconds When the job last SUCCEEDED."
        echo "# TYPE nightly_job_last_success_timestamp_seconds gauge"
        echo "nightly_job_last_success_timestamp_seconds $end"
    fi
} > "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$textfile_dir/nightly_job.prom"     # atomic: node-exporter never reads a half-written file
echo "nightly job finished: success=$success"
exit "$status"
