#!/usr/bin/env bash
# disk-full — the reference fix: buy time, then fix the policy
df -h /var/log/demo-app; du -sh /var/log/demo-app/* | sort -h
rm /var/log/demo-app/app.log.[3-6]                              # oldest first (or archive them somewhere else)
gzip /var/log/demo-app/app.log.[12]                             # text logs compress ~10x
cat > /etc/logrotate.d/demo-app <<'EOF'
/var/log/demo-app/*.log {
    daily
    rotate 7
    maxsize 20M
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF
logrotate -d /etc/logrotate.d/demo-app 2>&1 | tail -3           # dry run: no errors
df -h /var/log/demo-app
