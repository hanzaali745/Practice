#!/usr/bin/env bash
# nginx-502 — the reference fix
tail -3 /var/log/nginx/error.log                                # connect() failed (111: Connection refused) ... upstream: "http://127.0.0.1:8001/"
ss -tlnp | grep -E ':(80|8000|8001) '                           # the app listens on 8000, nothing on 8001
sed -i 's|proxy_pass http://127.0.0.1:8001;.*|proxy_pass http://127.0.0.1:8000;|' /etc/nginx/sites-available/default
nginx -t && systemctl reload nginx
curl -s localhost/health
