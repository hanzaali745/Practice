#!/usr/bin/env bash
# Module 05 labs — reference solution. Run: sudo ./labs.sh   (safe to run again)
set -euo pipefail

# Lab 1 — your own long-running service, done right
cat > /usr/local/bin/lab-heartbeat <<'EOF'
#!/bin/sh
# prints a line every 10 s: systemd sends stdout to the journal
while true; do
    echo "heartbeat $(date -Is)"
    sleep 10
done
EOF
chmod 755 /usr/local/bin/lab-heartbeat
cat > /etc/systemd/system/lab-heartbeat.service <<'EOF'
[Unit]
Description=Lab heartbeat (prints a line every 10 seconds)
After=network.target

[Service]
ExecStart=/usr/local/bin/lab-heartbeat
# a throw-away user created by systemd for this service: never root
DynamicUser=yes
Restart=on-failure
RestartSec=5
# hardening: the service can't write to the OS or see home directories
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

# Lab 2 — a scheduled job: a timer + a oneshot service (the systemd way to do cron)
cat > /etc/systemd/system/lab-report.service <<'EOF'
[Unit]
Description=Write a small system report

[Service]
Type=oneshot
DynamicUser=yes
# systemd creates /var/lib/lab-report, owned by the dynamic user
StateDirectory=lab-report
ExecStart=/bin/sh -c '{ date -Is; uptime; df -h /; } > /var/lib/lab-report/report.txt'
EOF
cat > /etc/systemd/system/lab-report.timer <<'EOF'
[Unit]
Description=Daily system report at 02:00

[Timer]
OnCalendar=*-*-* 02:00:00
# run at boot if the machine was off at 02:00
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now lab-heartbeat.service lab-report.timer
systemctl list-timers lab-report.timer --no-pager

# Lab 3 — cap the journal's disk use (drop-in: never edit the vendor file)
mkdir -p /etc/systemd/journald.conf.d
printf '[Journal]\nSystemMaxUse=200M\n' > /etc/systemd/journald.conf.d/lab.conf
systemctl restart systemd-journald
journalctl --disk-usage

# Lab 4 — servers run on UTC (logs from many machines line up)
timedatectl set-timezone UTC
timedatectl show -p Timezone

sleep 2; journalctl -u lab-heartbeat -n 3 --no-pager
