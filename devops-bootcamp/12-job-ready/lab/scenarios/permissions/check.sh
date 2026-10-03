ok "demo-app is active" systemctl is-active demo-app
ok "the demo user can read app.py" sudo -u demo test -r /opt/demo-app/app.py
ok "app.py is not world-writable (chmod 777 is not a fix)" not_world_writable /opt/demo-app/app.py
ok "/opt/demo-app is not world-writable" not_world_writable /opt/demo-app
ok "users get the real app through nginx" app_healthy
finish
