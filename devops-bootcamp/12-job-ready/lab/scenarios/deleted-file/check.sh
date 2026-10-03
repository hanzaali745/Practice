below() { (( $(use_pct /var/log/demo-app) < $1 )); }
no_deleted_open_files() { [[ -z $(lsof -t -a +L1 /var/log/demo-app 2> /dev/null) ]]; }
shipper_stopped() { ! systemctl is-active --quiet log-shipper; }
ok "/var/log/demo-app is below 30% full (now: $(use_pct /var/log/demo-app)%)" below 30
ok "no deleted-but-open files on /var/log/demo-app" no_deleted_open_files
ok "the obsolete log-shipper is stopped" shipper_stopped
ok "users get the real app through nginx" app_healthy
finish
