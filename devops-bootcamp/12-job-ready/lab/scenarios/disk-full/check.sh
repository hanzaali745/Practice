conf=/etc/logrotate.d/demo-app
below() { (( $(use_pct /var/log/demo-app) < $1 )); }
few_rotations() { (( $(awk '$1 == "rotate" {print $2}' "$conf") <= 30 )); }
ok "/var/log/demo-app is below 60% full (now: $(use_pct /var/log/demo-app)%)" below 60
ok "rotated logs are compressed" grep -qw compress "$conf"
ok "only a sane number of rotations are kept (≤ 30)" few_rotations
ok "log size is capped (size/maxsize)" grep -qE '^\s*(max)?size\s' "$conf"
ok "the logrotate config is valid" logrotate -d "$conf"
ok "users get the real app through nginx" app_healthy
finish
