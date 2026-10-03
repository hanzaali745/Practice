cat > /usr/local/bin/nightly-report <<'EOF'
#!/bin/bash
# nightly-report — builds the sales report. (BUG: spins forever when the report table is empty)
exec 9> /run/nightly-report.lock
flock -n 9 || exit 0
while :; do :; done
EOF
chmod 755 /usr/local/bin/nightly-report
echo '* * * * * root /usr/local/bin/nightly-report' > /etc/cron.d/nightly-report
setsid -f /usr/local/bin/nightly-report > /dev/null 2>&1
