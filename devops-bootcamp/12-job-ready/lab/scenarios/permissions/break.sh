# an over-eager "hardening" script locked down the app code so the service user can't read it
chown root:root /opt/demo-app/app.py
chmod 600 /opt/demo-app/app.py
chmod 700 /opt/demo-app
systemctl restart demo-app || true
