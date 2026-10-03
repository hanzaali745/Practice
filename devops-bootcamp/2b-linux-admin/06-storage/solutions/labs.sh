#!/usr/bin/env bash
# Module 06 labs — reference solution. Run on your lab VM: sudo ./labs.sh   (safe to run again)
# The "disks" are image files attached as loop devices — real partitioning commands, zero risk to your real disk.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

# Lab 1 — three empty "disks" (sparse files: they only use space when written)
mkdir -p /var/lib/lab-disks
[[ -f /var/lib/lab-disks/disk1.img ]] || truncate -s 1G /var/lib/lab-disks/disk1.img
[[ -f /var/lib/lab-disks/disk2.img ]] || truncate -s 512M /var/lib/lab-disks/disk2.img
[[ -f /var/lib/lab-disks/disk3.img ]] || truncate -s 512M /var/lib/lab-disks/disk3.img

# real disks exist at boot; ours must be attached at boot — a small oneshot service does that
install -m 755 "$here/lab-disks" /usr/local/sbin/lab-disks
cat > /etc/systemd/system/lab-disks.service <<'EOF'
[Unit]
Description=Attach the lab's disk images as loop devices (so /etc/fstab can mount them at boot)
DefaultDependencies=no
After=systemd-remount-fs.service
Before=local-fs-pre.target
Wants=local-fs-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/lab-disks

[Install]
WantedBy=local-fs.target
EOF
systemctl daemon-reload
systemctl enable lab-disks.service
/usr/local/sbin/lab-disks
loop_of() { losetup -j "/var/lib/lab-disks/$1" | cut -d: -f1; }
d1=$(loop_of disk1.img)
lsblk "$d1"

# Lab 2 — partition, format, mount by UUID in /etc/fstab
if ! blkid -p "$d1" &> /dev/null; then                  # only if the disk is still blank!
    parted -s "$d1" mklabel gpt mkpart data ext4 1MiB 100%
fi
udevadm settle                                           # wait for /dev/loopXp1 to appear
# a new partition already has a label and PARTUUID — ask for a FILE SYSTEM type, or you would never format it
[[ -n $(blkid -p -s TYPE -o value "${d1}p1" 2> /dev/null) ]] || mkfs.ext4 -q -L data "${d1}p1"
uuid=$(blkid -s UUID -o value "${d1}p1")
[[ -n $uuid ]] || { echo "no UUID on ${d1}p1 — is it formatted?" >&2; exit 1; }
mkdir -p /data
grep -q "UUID=$uuid" /etc/fstab || echo "UUID=$uuid /data ext4 defaults,nofail 0 2  # lab-managed" >> /etc/fstab
systemctl daemon-reload                                  # systemd generates mount units from fstab
findmnt --verify
mountpoint -q /data || mount /data
df -h /data

# Lab 3 — a swap file on the new disk
if [[ ! -f /data/swapfile ]]; then
    fallocate -l 256M /data/swapfile
    chmod 600 /data/swapfile
    mkswap /data/swapfile
fi
grep -q '^/data/swapfile' /etc/fstab || echo "/data/swapfile none swap sw,nofail 0 0  # lab-managed" >> /etc/fstab
swapon --show=NAME --noheadings | grep -x /data/swapfile > /dev/null || swapon /data/swapfile
swapon --show

# Lab 4 — LVM: two small disks become one volume group; grow a volume while it's mounted
if ! grep -q device-mapper /proc/devices; then
    echo "⏭️  no device-mapper in this kernel (container/WSL?): skipping LVM — use a VM"
    exit 0
fi
d2=$(loop_of disk2.img)
d3=$(loop_of disk3.img)
vgs labvg &> /dev/null || { pvcreate -q "$d2" "$d3"; vgcreate -q labvg "$d2" "$d3"; }
lvs labvg/data &> /dev/null || lvcreate -q -y -L 500M -n data labvg
[[ -n $(blkid -p -s TYPE -o value /dev/labvg/data 2> /dev/null) ]] || mkfs.ext4 -q -L lvdata /dev/labvg/data
mkdir -p /srv/data
grep -q '^/dev/mapper/labvg-data' /etc/fstab || echo "/dev/mapper/labvg-data /srv/data ext4 defaults,nofail 0 2  # lab-managed" >> /etc/fstab
systemctl daemon-reload
mountpoint -q /srv/data || mount /srv/data
# grow by 300 MiB — -r resizes the file system too, online
(( $(lvs --noheadings --units m --nosuffix -o lv_size labvg/data | cut -d. -f1 | tr -d ' ') >= 700 )) || lvextend -q -r -L +300M labvg/data
pvs; vgs; lvs; df -h /srv/data
