#!/usr/bin/env bash
# Module 07 labs — reference solution (needs modules 02 and 05). Run: sudo ./labs.sh   (safe to run again)
set -euo pipefail

# Lab 2 — kernel parameters, now AND after reboot
cat > /etc/sysctl.d/90-lab.conf <<'EOF'
# a longer listen queue for busy web servers
net.core.somaxconn = 1024
# more ports for outgoing connections (proxies, load generators)
net.ipv4.ip_local_port_range = 10240 65000
EOF
sysctl -p /etc/sysctl.d/90-lab.conf           # apply just this file (sysctl --system applies all of them)

# Lab 3 — more open files for one service (systemd ignores limits.conf: use the unit)
mkdir -p /etc/systemd/system/lab-heartbeat.service.d
printf '[Service]\nLimitNOFILE=65536\n' > /etc/systemd/system/lab-heartbeat.service.d/limits.conf
systemctl daemon-reload
systemctl restart lab-heartbeat
grep 'Max open files' "/proc/$(systemctl show -p MainPID --value lab-heartbeat)/limits"

# ...and for people who log in (PAM reads limits.d at login)
cat > /etc/security/limits.d/90-lab.conf <<'EOF'
# <domain> <type> <item>  <value>
@devteam    soft   nofile  4096
@devteam    hard   nofile  8192
EOF
sudo -i -u alice sh -c 'ulimit -Sn; ulimit -Hn'      # a new login session as alice → 4096 / 8192
