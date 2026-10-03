# A small Ubuntu 24.04 "server" for Ansible practice: systemd, SSH (key-only), Python, sudo.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv openssh-server openssh-sftp-server python3 python3-apt sudo iproute2 ca-certificates

# NOTE: we keep /var/lib/apt/lists (unlike most images) so the fleet behaves like a real server:
# `ansible-playbook --check` can then see which packages exist without refreshing the apt cache.

# The admin user Ansible logs in as (passwordless sudo, like a cloud VM's default user)
RUN useradd --create-home --shell /bin/bash devops \
 && echo "devops ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devops \
 && chmod 0440 /etc/sudoers.d/devops \
 && install -d -m 0700 -o devops -g devops /home/devops/.ssh

# Key-only SSH; start sshd at boot (Ubuntu 24.04 otherwise uses on-demand socket activation)
RUN sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config \
 && systemctl disable ssh.socket \
 && systemctl enable ssh.service \
 && rm -f /etc/ssh/ssh_host_*_key*   # each container generates its own host keys at boot

# Generate host keys on first boot
RUN printf '[Unit]\nDescription=Generate SSH host keys\nBefore=ssh.service\n[Service]\nType=oneshot\nExecStart=/usr/bin/ssh-keygen -A\n[Install]\nWantedBy=multi-user.target\n' \
      > /etc/systemd/system/ssh-hostkeys.service \
 && systemctl enable ssh-hostkeys.service

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
