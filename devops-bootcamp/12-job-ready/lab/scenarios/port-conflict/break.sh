systemctl stop demo-app
# a "temporary" debug web server, left running on the app's port
systemd-run --unit=debug-server --description="python http.server (debugging, remove me)" --uid=nobody \
    --working-directory=/tmp python3 -m http.server 8000 --bind 127.0.0.1 > /dev/null 2>&1
sleep 1
systemctl start demo-app || true
