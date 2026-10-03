ok "the name redis resolves" getent hosts redis
ok "/visits works again (Redis reachable)" is_http http://localhost/visits 200
ok "users get the real app through nginx" app_healthy
finish
