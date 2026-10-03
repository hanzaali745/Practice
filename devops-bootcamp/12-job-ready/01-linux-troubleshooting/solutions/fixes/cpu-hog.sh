# cpu-hog — the reference fix: stop the cause, then the symptom
ps aux --sort=-%cpu | head -3                                   # root ... /bin/bash /usr/local/bin/nightly-report
grep -r nightly-report /etc/cron.d/                             # /etc/cron.d/nightly-report: * * * * * root ...
sed -i 's/^\*/# disabled OPS-4242 (spins on empty table): */' /etc/cron.d/nightly-report
pkill -f /usr/local/bin/nightly-report
sleep 1; pgrep -fa nightly-report || echo "not running"
