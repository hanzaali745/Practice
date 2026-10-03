# MAINTAINER TEST IMAGE — not for learners (learners use a real VM: ../new-vm.sh).
# A systemd Ubuntu 24.04 container that stands in for the lab VM, so test_linux_lab.sh can prove every lab
# solution makes check.sh pass. Two small shims replace what a container lacks (see shims/).
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus sudo openssh-server ufw lvm2 acl parted fdisk e2fsprogs \
      cron logrotate procps psmisc iproute2 kmod less file plocate curl ca-certificates python3 nginx \
 && apt-get install -y --download-only tree jq unattended-upgrades
# containers have no udev: let LVM manage its own device nodes
RUN sed -i 's/^\(\s*\)# udev_sync = 1/\1udev_sync = 0/; s/^\(\s*\)# udev_rules = 1/\1udev_rules = 0/' /etc/lvm/lvm.conf \
 && systemctl mask systemd-logind.service getty.target console-getty.service
COPY shims/udevadm shims/apt-get /usr/local/sbin/
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
