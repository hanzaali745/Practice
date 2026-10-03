#!/usr/bin/env bash
# check.sh MODULE|all — did the labs of a Linux-admin module leave your lab VM in the right state?
#   sudo ./check.sh 02        users, groups and sudo
#   sudo ./check.sh all       everything (the capstone's definition of "done")
# Read-only: it only looks. Run it INSIDE your lab VM, as root (sudo).
# shellcheck disable=SC2329  # the check helpers are called through ok()
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "run me with sudo" >&2; exit 2; }

failed=0
ok() {                                   # ok "description" command args...
    local desc=$1
    shift
    if "$@" > /dev/null 2>&1; then echo "  ✅ $desc"; else echo "  ❌ $desc"; failed=1; fi
}
skip() { echo "  ⏭️  $1"; }
in_group() { id -nG "$1" 2> /dev/null | tr ' ' '\n' | grep -x "$2"; }   # (no grep -q after a pipe: SIGPIPE + pipefail)
mode_is() { [[ $(stat -c %a "$1") == "$2" ]]; }
owner_is() { [[ $(stat -c %U:%G "$1") == "$2" ]]; }
as() { sudo -u "$1" -- "${@:2}"; }

# ---------------------------------------------------------------- 01
check_01() {
    echo "01 · Filesystem & files"
    local d=/srv/lab/links
    same_inode() { [[ $(stat -c %i "$d/original.txt") == $(stat -c %i "$d/hard.txt") ]]; }
    soft_ok() { [[ -L $d/soft.txt && $(readlink "$d/soft.txt") == original.txt ]]; }
    backup_ok() { tar -tzf /var/backups/lab/etc-backup.tar.gz | grep -x 'etc/hostname'; }
    backup_perms() { tar -tvzf /var/backups/lab/etc-backup.tar.gz etc/shadow | grep '^-rw-r-----'; }
    big_files_ok() {
        local f=/srv/lab/find/big-files.txt line
        [[ -s $f ]] || return 1
        while IFS= read -r line; do [[ -f $line && $(stat -c %s "$line") -gt 1048576 ]] || return 1; done < "$f"
    }
    ok "hard.txt is a hard link to original.txt (same inode)" same_inode
    ok "soft.txt is a symlink pointing to original.txt" soft_ok
    ok "/var/backups/lab/etc-backup.tar.gz contains etc/hostname" backup_ok
    ok "the backup kept permissions (etc/shadow is -rw-r-----)" backup_perms
    ok "/srv/lab/find/big-files.txt lists only real files > 1 MiB" big_files_ok
}

# ---------------------------------------------------------------- 02
check_02() {
    echo "02 · Users, groups & sudo"
    home_shell() { [[ $(getent passwd "$1" | cut -d: -f6,7) == "/home/$1:/bin/bash" && -d /home/$1 ]]; }
    bob_rule() {
        local rules
        rules=$(sudo -l -U bob 2> /dev/null)
        grep -q 'NOPASSWD: */usr/bin/systemctl restart nginx' <<< "$rules" && ! grep -qE '\(ALL( : ALL)?\) ALL' <<< "$rules"
    }
    sudoers_file_ok() { [[ -f /etc/sudoers.d/bob-nginx ]] && mode_is /etc/sudoers.d/bob-nginx 440 && visudo -cf /etc/sudoers.d/bob-nginx; }
    system_user() {
        local uid shell home
        IFS=: read -r _ _ uid _ _ home shell < <(getent passwd svc-backup)
        (( uid < 1000 )) && [[ $shell == */nologin && ! -e $home ]]
    }
    locked() { [[ $(passwd -S carol | awk '{print $2}') == L ]]; }
    expired() { local d; d=$(getent shadow carol | cut -d: -f8); [[ -n $d ]] && (( d <= $(date +%s) / 86400 )); }
    max_days() { [[ $(getent shadow alice | cut -d: -f5) == 90 ]]; }
    ok "group devteam exists" getent group devteam
    ok "alice: home /home/alice, shell /bin/bash" home_shell alice
    ok "alice is in devteam" in_group alice devteam
    ok "alice is in sudo" in_group alice sudo
    ok "alice must change her password every 90 days" max_days
    ok "bob: home /home/bob, shell /bin/bash, in devteam" bash -c "getent passwd bob | grep ':/home/bob:/bin/bash$' && id -nG bob | grep -w devteam"
    ok "bob is NOT in the sudo group" bash -c "! id -nG bob | grep -qw sudo"
    ok "bob may run ONLY 'systemctl restart nginx' as root, without a password" bob_rule
    ok "/etc/sudoers.d/bob-nginx is valid and mode 440" sudoers_file_ok
    ok "svc-backup is a system user: uid < 1000, nologin shell, no home" system_user
    ok "carol (left the company) is locked" locked
    ok "carol's account is expired" expired
}

# ---------------------------------------------------------------- 03
check_03() {
    echo "03 · Permissions in depth"
    local s=/srv/devteam
    shared_write() {
        as alice bash -c "umask 022; echo v1 > $s/.lab-check-alice" &&
        as bob bash -c "echo v2 >> $s/.lab-check-alice"
        local rc=$?
        rm -f "$s/.lab-check-alice"
        return "$rc"
    }
    auditor_reads() { as auditor ls "$s" && ! as auditor touch "$s/.lab-check-auditor"; }
    sticky_protects() {
        as alice touch /srv/dropbox/.lab-alice-file &&
        ! as bob rm -f /srv/dropbox/.lab-alice-file
        local rc=$?
        rm -f /srv/dropbox/.lab-alice-file
        return "$rc"
    }
    ok "$s: owner root, group devteam" owner_is "$s" root:devteam
    ok "$s: mode 2770 (setgid: new files get group devteam)" mode_is "$s" 2770
    ok "files alice creates there are writable by bob (default ACL)" shared_write
    ok "user auditor exists" id auditor
    ok "auditor can list $s but not write (ACL)" auditor_reads
    ok "/srv/dropbox has the sticky bit (mode 1777)" mode_is /srv/dropbox 1777
    ok "in /srv/dropbox, bob can't delete alice's file" sticky_protects
    ok "$s/RELEASE-LOCK is immutable (chattr +i)" bash -c "lsattr -d $s/RELEASE-LOCK | cut -c1-20 | grep i"
    ok "/srv/lab/setuid.txt lists setuid programs (incl. /usr/bin/passwd)" grep -qx /usr/bin/passwd /srv/lab/setuid.txt
}

# ---------------------------------------------------------------- 04
check_04() {
    echo "04 · Packages"
    installed() { [[ $(dpkg-query -W -f='${db:Status-Status}' "$1" 2> /dev/null) == installed ]]; }   # held packages are "hold ok installed"
    auto_upgrades() { apt-config dump | grep 'APT::Periodic::Unattended-Upgrade "1"'; }
    ok "tree is installed" installed tree
    ok "jq is installed" installed jq
    ok "tree is on hold (apt-mark hold)" bash -c "apt-mark showhold | grep -x tree"
    ok "your package hello-lab 1.0.0 is installed" bash -c "[[ \$(dpkg-query -W -f='\${Version}' hello-lab) == 1.0.0 ]]"
    ok "dpkg knows hello-lab owns /usr/bin/hello-lab" bash -c "dpkg -S /usr/bin/hello-lab | grep '^hello-lab:'"
    ok "hello-lab runs" bash -c "/usr/bin/hello-lab | grep -i hello"
    ok "unattended security upgrades are enabled" auto_upgrades
}

# ---------------------------------------------------------------- 05
check_05() {
    echo "05 · Services, boot & time"
    prop() { systemctl show -p "$2" --value "$1"; }
    non_root() { [[ $(prop lab-heartbeat DynamicUser) == yes || ( -n $(prop lab-heartbeat User) && $(prop lab-heartbeat User) != root ) ]]; }
    beating() { journalctl -u lab-heartbeat --since "-2min" --no-pager | grep heartbeat; }
    timer_02() { prop lab-report.timer TimersCalendar | grep '02:00:00'; }
    report_runs() { systemctl start lab-report.service && [[ -s /var/lib/lab-report/report.txt ]]; }
    journald_cap() { systemd-analyze cat-config systemd/journald.conf | grep -E '^SystemMaxUse=200M'; }
    ok "lab-heartbeat.service is enabled and running" bash -c "systemctl is-enabled lab-heartbeat && systemctl is-active lab-heartbeat"
    ok "it doesn't run as root" non_root
    ok "it restarts on failure" bash -c "[[ \$(systemctl show -p Restart --value lab-heartbeat) == on-failure ]]"
    ok "it logs 'heartbeat' to the journal" beating
    ok "lab-report.timer is enabled and active" bash -c "systemctl is-enabled lab-report.timer && systemctl is-active lab-report.timer"
    ok "the timer fires daily at 02:00" timer_02
    ok "lab-report.service is a oneshot" bash -c "[[ \$(systemctl show -p Type --value lab-report.service) == oneshot ]]"
    ok "running it writes /var/lib/lab-report/report.txt" report_runs
    ok "journald keeps at most 200M (drop-in)" journald_cap
    ok "the time zone is UTC" bash -c "[[ \$(timedatectl show -p Timezone --value) == UTC ]]"
}

# ---------------------------------------------------------------- 06
check_06() {
    echo "06 · Storage"
    fstab_has() { grep -E "^[^#]*[[:space:]]$1[[:space:]]" /etc/fstab; }
    ok "/data is mounted (ext4)" bash -c "[[ \$(findmnt -n -o FSTYPE /data) == ext4 ]]"
    ok "/data is in /etc/fstab by UUID, with nofail" bash -c "fstab_line=\$(grep -E '^[^#]*[[:space:]]/data[[:space:]]' /etc/fstab) && [[ \$fstab_line == UUID=* && \$fstab_line == *nofail* ]]"
    ok "/etc/fstab has no errors (findmnt --verify)" findmnt --verify
    ok "lab-disks.service re-attaches the disk images at boot" systemctl is-enabled lab-disks.service
    ok "the swap file /data/swapfile is active" bash -c "swapon --show=NAME --noheadings | grep -x /data/swapfile"
    ok "the swap file is in /etc/fstab" grep -qE '^/data/swapfile[[:space:]]+none[[:space:]]+swap' /etc/fstab
    if [[ -c /dev/mapper/control ]] && grep -q device-mapper /proc/devices; then
        ok "volume group labvg exists with 2 physical volumes" bash -c "[[ \$(vgs --noheadings -o pv_count labvg | tr -d ' ') == 2 ]]"
        ok "logical volume labvg/data is at least 700 MiB" bash -c "(( \$(lvs --noheadings --units m --nosuffix -o lv_size labvg/data | cut -d. -f1 | tr -d ' ') >= 700 ))"
        ok "/srv/data is mounted from labvg/data" bash -c "[[ \$(findmnt -n -o SOURCE /srv/data) == /dev/mapper/labvg-data ]]"
        ok "the file system on /srv/data was grown too (> 600 MiB)" bash -c "(( \$(df --output=size -m /srv/data | tail -1) > 600 ))"
        ok "/srv/data is in /etc/fstab" fstab_has /srv/data
    else
        skip "LVM checks skipped: this kernel has no device-mapper (containers/WSL) — use a VM"
    fi
}

# ---------------------------------------------------------------- 07
check_07() {
    echo "07 · Processes, resources & kernel"
    sysctl_is() { [[ $(sysctl -n "$1" | tr -s '\t ' ' ') == "$2" ]]; }
    nofile() { local pid; pid=$(systemctl show -p MainPID --value lab-heartbeat); grep -qE 'Max open files +65536 +65536' "/proc/$pid/limits"; }
    ok "/etc/sysctl.d/90-lab.conf sets net.core.somaxconn" grep -qE '^net\.core\.somaxconn *= *1024' /etc/sysctl.d/90-lab.conf
    ok "net.core.somaxconn is 1024 now" sysctl_is net.core.somaxconn 1024
    ok "net.ipv4.ip_local_port_range is 10240 65000 now (and in the file)" bash -c "grep -q ip_local_port_range /etc/sysctl.d/90-lab.conf && [[ \$(sysctl -n net.ipv4.ip_local_port_range | tr -s '\t ' ' ') == '10240 65000' ]]"
    ok "lab-heartbeat has LimitNOFILE=65536 (drop-in)" bash -c "[[ \$(systemctl show -p LimitNOFILE --value lab-heartbeat) == 65536 ]]"
    if (( $(awk '/Max open files/ {print $5}' /proc/1/limits) >= 65536 )); then
        ok "...and its running process really has it" nofile
    else
        skip "process limit check skipped: this machine caps open files below 65536 (container?)"
    fi
    ok "devteam users get nofile 4096 soft / 8192 hard (limits.d)" bash -c "grep -qE '^@devteam +soft +nofile +4096' /etc/security/limits.d/90-lab.conf && grep -qE '^@devteam +hard +nofile +8192' /etc/security/limits.d/90-lab.conf"
}

# ---------------------------------------------------------------- 08
check_08() {
    echo "08 · Networking & hardening"
    sshd_is() { sshd -T 2> /dev/null | grep -ix "$1 $2"; }
    ufw_has() { ufw status | grep -E "^$1 +ALLOW"; }
    ok "ufw is active" bash -c "ufw status | grep 'Status: active'"
    ok "ufw denies incoming by default" bash -c "ufw status verbose | grep 'deny (incoming)'"
    ok "ufw allows OpenSSH" ufw_has OpenSSH
    ok "ufw allows 80/tcp" ufw_has 80/tcp
    ok "sshd config is valid (sshd -t)" sshd -t
    ok "sshd: PermitRootLogin no" sshd_is permitrootlogin no
    ok "sshd: PasswordAuthentication no" sshd_is passwordauthentication no
    ok "sshd: KbdInteractiveAuthentication no" sshd_is kbdinteractiveauthentication no
    ok "sshd: MaxAuthTries 3" sshd_is maxauthtries 3
    ok "sshd: X11Forwarding no" sshd_is x11forwarding no
    ok "the settings live in /etc/ssh/sshd_config.d/50-lab-hardening.conf" test -f /etc/ssh/sshd_config.d/50-lab-hardening.conf
    ok "/srv/lab/listening.txt lists the listening TCP ports (from ss)" grep -qE ':22\b' /srv/lab/listening.txt
}

[[ -d /run/sshd ]] || install -d -m 755 /run/sshd                # sshd -t needs it on a freshly booted box
case ${1:-} in
    01 | 02 | 03 | 04 | 05 | 06 | 07 | 08) "check_$1" ;;
    all) for m in 01 02 03 04 05 06 07 08; do "check_$m"; done ;;
    *) echo "usage: sudo $0 01..08|all" >&2; exit 2 ;;
esac
echo
if (( failed )); then echo "❌ not there yet — fix the ❌ lines"; exit 1; fi
echo "✅ all good"
