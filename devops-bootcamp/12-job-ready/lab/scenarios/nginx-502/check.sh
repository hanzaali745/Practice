proxies_to_app() { grep -RqE 'proxy_pass http://(127\.0\.0\.1|localhost):8000;' /etc/nginx/sites-enabled/; }
ok "the nginx config is valid" nginx -t
ok "nginx proxies to the port demo-app listens on" proxies_to_app
ok "users get the real app through nginx" app_healthy
finish
