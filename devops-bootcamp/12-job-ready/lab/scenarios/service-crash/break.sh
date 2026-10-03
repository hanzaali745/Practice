# someone "tuned" the service with a drop-in override — and typed the letter O instead of a zero
mkdir -p /etc/systemd/system/demo-app.service.d
cat > /etc/systemd/system/demo-app.service.d/override.conf <<'EOF'
[Service]
# performance tuning (ticket OPS-1234)
Environment=PORT=8O00
Nice=-5
EOF
systemctl daemon-reload
systemctl restart demo-app || true
