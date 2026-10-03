# months ago, during an incident, someone set logrotate to "keep everything" — and never set it back
cat > /etc/logrotate.d/demo-app <<'EOF'
/var/log/demo-app/*.log {
    daily
    rotate 365
    missingok
    copytruncate
}
EOF
python3 - <<'EOF'
line = '{"@timestamp":"2026-01-01T00:00:00.000Z","log":{"level":"info"},"message":"GET / 200 1.2ms","service":{"name":"demo-app"}}\n'
for i in range(1, 7):                                    # six old, uncompressed rotations of ~10 MB each
    with open(f"/var/log/demo-app/app.log.{i}", "w") as f:
        f.write(line * (10_000_000 // len(line)))
EOF
chown demo:demo /var/log/demo-app/app.log.*
