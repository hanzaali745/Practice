# left behind from a Redis migration test three months ago
printf '\n# redis migration test (OPS-987) — temporary!\n10.255.255.1\tredis\n' >> /etc/hosts
systemctl restart demo-app
