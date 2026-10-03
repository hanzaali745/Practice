inodes_below() { (( $(inode_pct /var/log/demo-app) < $1 )); }
can_create_files() { touch /var/log/demo-app/.lab-check && rm /var/log/demo-app/.lab-check; }
ok "inode use on /var/log/demo-app is below 50% (now: $(inode_pct /var/log/demo-app)%)" inodes_below 50
ok "new files can be created there" can_create_files
ok "users get the real app through nginx" app_healthy
finish
