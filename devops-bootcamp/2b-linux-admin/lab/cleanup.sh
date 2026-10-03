#!/usr/bin/env bash
# cleanup.sh — undo everything the Linux-admin labs created on your lab VM, so you can start over.
#   sudo ./cleanup.sh
# Only touches lab objects (users alice/bob/carol/auditor/svc-backup, /srv/lab*, lab-* units, lab disks,
# fstab lines marked "# lab-managed", ...). Simplest of all, though: delete the VM and create a new one.
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "run me with sudo" >&2; exit 2; }
say() { echo "• $*"; }

say "firewall and SSH"
ufw --force reset > /dev/null 2>&1 && ufw --force disable > /dev/null 2>&1
rm -f /etc/ssh/sshd_config.d/50-lab-hardening.conf
sshd -t 2> /dev/null && systemctl try-reload-or-restart ssh 2> /dev/null

say "kernel parameters and limits (values stay until reboot)"
rm -f /etc/sysctl.d/90-lab.conf /etc/security/limits.d/90-lab.conf

say "services and timers"
systemctl disable --now lab-heartbeat.service lab-report.timer lab-report.service > /dev/null 2>&1
rm -rf /etc/systemd/system/lab-heartbeat.service /etc/systemd/system/lab-heartbeat.service.d \
       /etc/systemd/system/lab-report.service /etc/systemd/system/lab-report.timer /usr/local/bin/lab-heartbeat \
       /etc/systemd/journald.conf.d/lab.conf /var/lib/private/lab-report /var/lib/lab-report

say "storage: swap, mounts, LVM, loop disks, fstab lines"
swapoff /data/swapfile 2> /dev/null
umount /srv/data 2> /dev/null
umount /data 2> /dev/null
if command -v vgremove > /dev/null && vgs labvg > /dev/null 2>&1; then
    vgremove -f -y labvg > /dev/null 2>&1
fi
for img in /var/lib/lab-disks/*.img; do
    [[ -f $img ]] || continue
    for dev in $(losetup -j "$img" | cut -d: -f1); do
        pvremove -f -y "$dev" > /dev/null 2>&1
        losetup -d "$dev"
    done
done
systemctl disable lab-disks.service > /dev/null 2>&1
rm -rf /var/lib/lab-disks /etc/systemd/system/lab-disks.service /usr/local/sbin/lab-disks
sed -i '/# lab-managed$/d' /etc/fstab
rmdir /data /srv/data 2> /dev/null
systemctl daemon-reload
systemctl restart systemd-journald

say "packages"
apt-mark unhold tree > /dev/null 2>&1
apt-get purge -y -qq hello-lab tree jq > /dev/null 2>&1
rm -f /etc/apt/apt.conf.d/20auto-upgrades

say "files and directories"
chattr -i /srv/devteam/RELEASE-LOCK 2> /dev/null
rm -rf /srv/devteam /srv/dropbox /srv/lab /var/backups/lab /tmp/restore

say "users, groups and sudo rules"
rm -f /etc/sudoers.d/bob-nginx
for u in alice bob carol auditor; do id "$u" > /dev/null 2>&1 && userdel -r "$u" 2> /dev/null; done
id svc-backup > /dev/null 2>&1 && userdel svc-backup
getent group devteam > /dev/null && groupdel devteam
echo "✅ lab state removed (time zone left as is)"
