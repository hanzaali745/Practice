# Linux Module 09 — Capstone: Build a Server from Scratch 🏆

## 🎯 The goal
Take a **brand-new** Ubuntu VM and turn it into the finished lab server — users and sudo, a shared team folder, packages
and auto-updates, your own services and timer, a data disk with swap and LVM, kernel tuning and limits, a firewall and
hardened SSH — with **one script, in one run, that you can run again safely**. Then prove it with the checker.

This is exactly what configuration management does. In Phase 7 you'll rebuild the same thing with Ansible and see how
much it gives you for free.

---

## 🛠️ Project 1 ⭐⭐⭐ — `provision.sh`

Write `provision.sh` so that this works on a fresh VM:
```bash
cd ~/Practice/devops-bootcamp/2b-linux-admin/lab
./new-vm.sh --delete; ./new-vm.sh && multipass shell linuxlab       # a FRESH machine
cd ~/Practice/devops-bootcamp/2b-linux-admin
sudo ../my-work/linux/provision.sh                                   # your script (in your my-work folder)
sudo ../my-work/linux/provision.sh                                   # again: must succeed and change nothing important
sudo lab/check.sh all                                                # every check from modules 01–08 passes
sudo reboot   # ...log in again:
sudo lab/check.sh all                                                # and still passes after a reboot
```

**Requirements**
- **Idempotent:** every step checks before it acts (`id user ||`, `grep -q ... ||`, "only format if there's no file
  system", `mkdir -p`, `ln -sfn`...). The second run must not fail, duplicate fstab lines, or reformat a disk.
- **Safe:** `set -euo pipefail`; validate before activating (`visudo -c`, `sshd -t`, `findmnt --verify`,
  `nginx -t`); allow SSH before enabling the firewall.
- **Ordered:** users before the folders they own; services before their limits; disks before swap on them.
- **Readable:** one function or section per area, with a comment saying *why*; a log of what happened.
- **Reboot-proof:** everything persists (enabled units, fstab, sysctl.d, limits.d, sshd_config.d).

The reference solution, [`solutions/provision.sh`](solutions/provision.sh), runs each module's idempotent lab
solution in order — compare it with yours after you've finished.

## 🛠️ Project 2 ⭐⭐ — Undo
Run `sudo lab/cleanup.sh` and read it: why does it go in roughly the **reverse** order of provisioning (firewall and
services first, users last)? Then make sure your provision script works again on the cleaned machine.

## 🛠️ Project 3 ⭐⭐⭐ — A web server baseline
Extend your script for a real role: install nginx, serve a static page from `/srv/www` (owned by a `www-deploy` user,
read-only for nginx), log rotation for its logs, ufw open only on 80/443, and a `deploy` sudo rule that may only
`systemctl reload nginx`. Write your own `check_web.sh` in the style of `lab/check.sh`.

## 🛠️ Project 4 ⭐⭐ — Write the runbook
Write `RUNBOOK.md` for this server: how to add a user, offboard a user, grow the data volume, rotate SSH keys, read
the logs of each service, and what every lab-* unit is for. A colleague should manage the box without asking you.

---

## ✅ Done when
- [ ] Your `provision.sh` turns a fresh VM into a server that passes `sudo lab/check.sh all`
- [ ] A second run succeeds without changing anything important
- [ ] The server passes again after a reboot
- [ ] You can explain every step — and why it's in that order

🎓 **Phase 2B complete!** Tick the [Linux expert checklist](../README.md#-linux-expert-checklist). Next comes Bash, where
your scripts get arrays, strict mode and remote execution — and you'll use this Linux knowledge in every module after it.

👉 Next phase: [Phase 3 — Bash](../../3-bash/README.md)
