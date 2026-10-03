# Linux Module 08 — Networking & Server Hardening 🔴

## 🎯 Objectives
- Read and configure a server's network: interfaces, addresses, routes, DNS (`ip`, netplan, `resolvectl`)
- See what's listening and who's connected (`ss`)
- Run a host firewall with `ufw` — without locking yourself out
- Harden SSH: keys only, no root login, sane limits — tested before reload
- Apply a baseline hardening checklist to every new server

## 🧠 Why DevOps engineers care
A fresh cloud VM is reachable from the whole internet within seconds, and bots start guessing SSH passwords
immediately. The first hour of any new server — firewall, SSH, updates, users — decides whether it ever becomes an
incident. (Phase 12 teaches *debugging* networks; this module teaches *configuring* and *securing* them.)

---

## 📖 Lesson 8.1 — Interfaces, addresses, routes

```bash
ip -br addr                      # interfaces and their IPs, briefly
ip route                         # routing table: "default via 10.0.0.1" = the gateway to everything else
ip -s link                       # packet/error counters per interface
ping -c3 1.1.1.1; ping -c3 example.com   # the network works / DNS works
```
On Ubuntu servers, the configuration lives in **netplan** (`/etc/netplan/*.yaml`):
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [10.0.0.10/24]
      routes: [{to: default, via: 10.0.0.1}]
      nameservers: {addresses: [10.0.0.2, 1.1.1.1]}
```
`sudo netplan try` applies it and **rolls back after 120 s** unless you confirm — use it on remote machines. Cloud VMs
normally use DHCP and you rarely touch this, but you must be able to read it.

## 📖 Lesson 8.2 — Names

`/etc/hostname`, `/etc/hosts` (local overrides), and DNS via **systemd-resolved** on Ubuntu: `/etc/resolv.conf` points
to the stub `127.0.0.53`; `resolvectl status` shows the real servers per interface; `resolvectl query example.com`
resolves through it.

## 📖 Lesson 8.3 — What's listening?

```bash
sudo ss -tlnp                    # TCP listening sockets + process     (-u for UDP)
sudo ss -tnp state established   # current connections
```
`0.0.0.0:22` / `[::]:22` = reachable on every interface; `127.0.0.1:5432` = local only. **Every listening port is
attack surface:** stop what you don't need, and bind internal services to `127.0.0.1` or a private interface.

## 📖 Lesson 8.4 — The firewall (ufw)

`ufw` is Ubuntu's front end for the kernel firewall (nftables/iptables):
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH            # ← BEFORE enabling, on any remote machine!
sudo ufw allow 80/tcp
sudo ufw allow from 10.0.0.0/24 to any port 5432 proto tcp   # a database: only from the app subnet
sudo ufw enable
sudo ufw status numbered; sudo ufw delete 3
```
In the cloud you also have **security groups** (Phase 11): use both — security groups at the edge, the host firewall as
defence in depth. On RHEL-family servers the equivalent is `firewalld` (`firewall-cmd`).

## 📖 Lesson 8.5 — Hardening SSH

Put your settings in a drop-in, `/etc/ssh/sshd_config.d/50-hardening.conf` — `sshd` uses the **first** value it reads
for each setting, and it reads `sshd_config.d/*.conf` before the rest of `sshd_config`:
```
PermitRootLogin no                 # log in as yourself, then sudo (audit trail!)
PasswordAuthentication no          # keys only: nothing to guess
KbdInteractiveAuthentication no
MaxAuthTries 3
X11Forwarding no
AllowGroups ssh-users              # optional: only members of this group may log in at all
```
```bash
sudo sshd -t                       # TEST the config — a broken sshd_config means nobody gets in again
sudo systemctl reload ssh          # reload keeps existing sessions alive
sudo sshd -T | grep -i passwordauth   # the EFFECTIVE values
```
**Keep your current session open** and test a *new* login in a second terminal before you log out. Keys: create with
`ssh-keygen -t ed25519`, install with `ssh-copy-id`. `fail2ban` can ban IPs that keep failing.

## 📖 Lesson 8.6 — A baseline for every new server

1. Update everything; enable unattended security updates (Module 04).
2. Personal accounts with SSH keys and narrow sudo; no shared accounts; root login off (Modules 02, 08).
3. Firewall: deny incoming by default, open only what's needed (8.4).
4. SSH hardened and tested (8.5).
5. Only needed services running and listening (`ss -tlnp`, `systemctl list-unit-files --state=enabled`).
6. Time sync, UTC, journal size limits (Module 05); disk usage monitored (Phase 9).
7. Everything above **in code** — the capstone's provisioning script now, Ansible roles in Phase 7.

Benchmarks like **CIS** and tools like **Lynis** (`sudo lynis audit system`) give you a fuller checklist.

---

## ⚠️ Common mistakes
- `ufw enable` on a remote server before allowing SSH — locked out
- Editing `sshd_config` and reloading without `sshd -t`, or logging out before testing a new login
- Password SSH open to the internet; root login allowed; one shared key for the whole team
- Services listening on `0.0.0.0` that should be local only (databases, admin panels)
- Hardening by hand on one server and forgetting it on the next

---

## 🧪 Labs
On your lab VM (Multipass keeps working: it logs in with keys). Reference solution: [`solutions/labs.sh`](solutions/labs.sh).
Check: `sudo lab/check.sh 08`.

### Lab 1 ⭐ — Inventory
Write the output of `ss -tlnp` to `/srv/lab/listening.txt`. For every listening port: which program, which
interface, is it needed? Read `/etc/netplan/*.yaml` and `resolvectl status` and explain them.

### Lab 2 ⭐⭐ — Firewall
Deny incoming by default, allow OpenSSH and 80/tcp, enable ufw. From your laptop, prove 22 works and another port
(e.g. start `python3 -m http.server 8000` on the VM) is blocked. Add a rule for 8000 from your laptop's IP only, then remove it.

### Lab 3 ⭐⭐⭐ — SSH hardening
Create `/etc/ssh/sshd_config.d/50-lab-hardening.conf`: no root login, no passwords, no keyboard-interactive,
`MaxAuthTries 3`, no X11 forwarding. Test with `sshd -t`, reload, check `sshd -T`, and confirm a **new**
`multipass shell linuxlab` still works.

### Lab 4 ⭐⭐ — Audit
Install and run `lynis audit system`. Pick the three most important suggestions and fix them (or explain why not).

---

## ✅ Checkpoint
- [ ] I can read and change a server's network configuration safely (`netplan try`)
- [ ] I know what listens on my servers and why
- [ ] I can run ufw without locking myself out
- [ ] I can harden SSH and verify the effective configuration
- [ ] I can apply the new-server baseline from memory
- [ ] `sudo lab/check.sh 08` passes

👉 Next: [Module 09 — Capstone: Build a Server](../09-capstone/README.md)
