#!/usr/bin/env bash
# port-conflict — the reference fix
ss -tlnp 'sport = :8000'                                        # users:(("python3",pid=...)) — but which python?
pid=$(ss -Htlnp 'sport = :8000' | grep -oP 'pid=\K[0-9]+' | head -1)
ps -o pid,user,cmd -p "$pid"                                    # nobody  python3 -m http.server 8000
systemctl status "$pid" --no-pager | head -2                    # ● debug-server.service
journalctl -u demo-app -n 5 --no-pager                          # OSError: [Errno 98] Address already in use
systemctl stop debug-server
systemctl restart demo-app
sleep 1; curl -s localhost/health
