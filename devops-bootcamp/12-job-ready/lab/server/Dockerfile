# A small Ubuntu 24.04 "production server" to troubleshoot: systemd, nginx → demo-app, and the usual diagnostic tools.
# lab.sh builds it and breaks it in realistic ways; your job is to find out why, and fix it properly.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv cron logrotate sudo less nano vim-tiny ca-certificates \
      nginx python3 openssl \
      procps psmisc sysstat lsof strace htop ncdu \
      iproute2 iputils-ping dnsutils curl netcat-openbsd traceroute tcpdump iptables nftables \
 && rm -rf /var/lib/apt/lists/*

# demo-app (Phase 4) as a systemd service, behind nginx — the classic "app server" layout
RUN groupadd --system --gid 900 demo \
 && useradd --system --uid 900 --gid 900 --home /opt/demo-app --shell /usr/sbin/nologin demo \
 && install -d -o demo -g demo /opt/demo-app /var/log/demo-app
COPY app.py /opt/demo-app/app.py
COPY demo-app.service /etc/systemd/system/demo-app.service
COPY nginx-site.conf /etc/nginx/sites-available/default
COPY demo-app.logrotate /etc/logrotate.d/demo-app
RUN systemctl enable demo-app.service nginx.service cron.service \
 && systemctl mask systemd-logind.service getty.target console-getty.service

# the person on call: you (passwordless sudo, like a cloud VM's default user)
RUN useradd --create-home --shell /bin/bash oncall \
 && echo "oncall ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/oncall \
 && chmod 0440 /etc/sudoers.d/oncall

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
