not_running() { ! pgrep -f /usr/local/bin/nightly-report; }
cron_disabled() { ! grep -rqsE '^[^#]*nightly-report' /etc/cron.d /etc/crontab /var/spool/cron; }
ok "nightly-report is not running" not_running
ok "cron won't start it again" cron_disabled
ok "users get the real app through nginx" app_healthy
finish
