sed -i 's|proxy_pass http://127.0.0.1:8000;|proxy_pass http://127.0.0.1:8001;   # moved to the new port (OPS-2201)|' /etc/nginx/sites-available/default
systemctl reload nginx
