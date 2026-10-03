not_crash_looping() { [[ $(systemctl show -p NRestarts --value demo-app) == 0 ]]; }
port_is_8000() { systemctl show -p Environment --value demo-app | grep -qw PORT=8000; }
ok "demo-app is active" systemctl is-active demo-app
ok "it is not crash-looping (no automatic restarts since you started it)" not_crash_looping
ok "the effective PORT is 8000" port_is_8000
ok "users get the real app through nginx" app_healthy
finish
