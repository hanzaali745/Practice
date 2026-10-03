#!/bin/bash
# user-data.sh — runs ONCE, as root, on the first boot of every instance (cloud-init). Installs demo-app as a service.
# Logs: /var/log/cloud-init-output.log on the instance. Written for Amazon Linux 2023 (has python3 and curl).
set -euxo pipefail

APP_URL="${APP_URL:-https://raw.githubusercontent.com/YOUR-USER/Practice/master/devops-bootcamp/4-docker/app/app.py}"
APP_VERSION="${APP_VERSION:-1.0.0}"

useradd --system --no-create-home --shell /sbin/nologin demoapp || true
mkdir -p /opt/demo-app
curl -fsSL --retry 5 "$APP_URL" -o /opt/demo-app/app.py

# Which instance answered? Ask the metadata service (IMDSv2: get a token first)
token=$(curl -fsS -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
instance_id=$(curl -fsS -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/instance-id)

cat > /etc/systemd/system/demo-app.service <<UNIT
[Unit]
Description=demo-app
After=network-online.target

[Service]
User=demoapp
Environment=PORT=8000 APP_VERSION=$APP_VERSION LOG_FORMAT=json "APP_MESSAGE=Hello from $instance_id"
ExecStart=/usr/bin/python3 /opt/demo-app/app.py
Restart=on-failure
NoNewPrivileges=true
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now demo-app
