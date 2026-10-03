no_stale_entry() { ! grep -qE '^[^#]*10\.255\.255\.1' /etc/hosts; }
resolvers_agree() { [[ $(getent hosts redis | awk '{print $1}') == "$(dig +short redis | head -1)" ]]; }
ok "/etc/hosts has no stale redis entry" no_stale_entry
ok "getent and DNS agree on redis" resolvers_agree
ok "/visits works again" is_http http://localhost/visits 200
ok "users get the real app through nginx" app_healthy
finish
