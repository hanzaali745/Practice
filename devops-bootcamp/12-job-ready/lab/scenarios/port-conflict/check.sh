debug_server_gone() { ! systemctl is-active --quiet debug-server; }
port_owner() { ps -o user= -p "$(ss -Htlnp 'sport = :8000' | grep -oP 'pid=\K[0-9]+' | head -1)"; }
demo_owns_port() { [[ $(port_owner) == demo ]]; }
ok "the debug server is gone" debug_server_gone
ok "demo-app is active" systemctl is-active demo-app
ok "port 8000 belongs to the demo user's process" demo_owns_port
ok "users get the real app through nginx" app_healthy
finish
