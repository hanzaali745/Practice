# service-crash — the reference fix (run as root on the server)
systemctl status demo-app --no-pager || true                    # activating (auto-restart), exit-code
journalctl -u demo-app -n 20 --no-pager                         # ValueError: invalid literal for int() ... '8O00'
systemctl cat demo-app                                          # the drop-in override.conf sets PORT=8O00
sed -i 's/^Environment=PORT=8O00$/Environment=PORT=8000/' /etc/systemd/system/demo-app.service.d/override.conf
systemctl daemon-reload                                         # systemd re-reads unit files only now
systemctl restart demo-app
curl -s localhost/health
