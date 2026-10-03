# Linux Module 04 — Packages & Software 🟡

## 🎯 Objectives
- Install, upgrade, remove and inspect software with `apt` and `dpkg`
- Understand repositories, signing keys and the `.sources` format — and add a third-party repo safely
- Pin or hold versions, and know what changes on `upgrade` vs `full-upgrade`
- Build and install your own `.deb` package
- Keep servers patched automatically with unattended-upgrades
- Know the other ways software arrives: snap, tarballs, `/usr/local` and `/opt`, and RPM-based distributions

## 🧠 Why DevOps engineers care
Every Dockerfile has an `apt-get install` line, every Ansible role installs packages, and most security fixes reach
you as package updates. Knowing exactly what a package installs, where it came from and which version you'll get is
the difference between reproducible servers and "works on my machine".

---

## 📖 Lesson 4.1 — Everyday apt

```bash
sudo apt update                   # refresh the package LISTS from the repositories (doesn't install anything)
apt list --upgradable             # what would change
sudo apt upgrade                  # upgrade installed packages (never removes packages)
sudo apt full-upgrade             # may also remove/replace packages to resolve changes (kernel, big upgrades)
sudo apt install nginx=1.24.*     # install (optionally a specific version)
sudo apt remove nginx             # remove, keep config files ·  sudo apt purge nginx  → remove config too
sudo apt autoremove               # remove dependencies nothing needs any more
apt search ripgrep; apt show jq   # find / describe
```
In scripts and Dockerfiles use **`apt-get`** (stable output for machines) with `-y` and `DEBIAN_FRONTEND=noninteractive`.

## 📖 Lesson 4.2 — dpkg: what's actually on disk

```bash
dpkg -l | grep nginx              # installed packages (ii = installed OK)
dpkg -L tree                      # every file a package installed
dpkg -S /usr/bin/curl             # which package owns this file?
dpkg -s jq                        # status, version, dependencies
apt-cache policy jq               # installed version, candidate version, and which repository each comes from
apt-cache rdepends --installed libssl3t64   # what depends on this?
```
`dpkg` installs single `.deb` files but doesn't fetch dependencies; `apt install ./file.deb` does both.

## 📖 Lesson 4.3 — Repositories and keys

Ubuntu 24.04 lists repositories in `/etc/apt/sources.list.d/*.sources` (deb822 format):
```
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```
Adding a vendor's repository — the safe pattern (you'll use it for Docker, Kubernetes and Terraform in setup part 2):
```bash
curl -fsSL https://vendor.example/key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/vendor.gpg
echo "deb [signed-by=/etc/apt/keyrings/vendor.gpg] https://vendor.example/apt noble main" | sudo tee /etc/apt/sources.list.d/vendor.list
sudo apt update
```
`signed-by` limits that key to **that** repository (the old `apt-key add` trusted it for everything — deprecated).
PPAs (`add-apt-repository ppa:...`) are convenient but are someone else's builds: use them sparingly.

## 📖 Lesson 4.4 — Holding and pinning

```bash
sudo apt-mark hold kubelet         # never upgrade it automatically (Kubernetes nodes do this)
apt-mark showhold
sudo apt-mark unhold kubelet
```
**Pinning** (`/etc/apt/preferences.d/`) sets priorities per package/repository, e.g. "take `nginx` from the vendor
repo, everything else from Ubuntu". In Dockerfiles, pin versions (`apt-get install -y curl=8.5.*`) when reproducibility
matters more than getting the latest patch.

## 📖 Lesson 4.5 — Your own .deb

A package is an archive of files plus a `DEBIAN/control` file with metadata:
```
hello-lab_1.0.0_all/
├── DEBIAN/control         Package, Version, Architecture, Maintainer, Description, (Depends)
└── usr/bin/hello-lab      files exactly where they'll be installed
```
```bash
dpkg-deb --build --root-owner-group hello-lab_1.0.0_all      # → hello-lab_1.0.0_all.deb
sudo apt install ./hello-lab_1.0.0_all.deb
dpkg -L hello-lab; sudo apt remove hello-lab
```
Real packages go into `/usr/bin`; `/usr/local` and `/opt` are for things you install **without** a package manager
(tarballs, `make install`), so the two never collide. Teams package internal tools as `.deb`s (with tools like `fpm` or
`nfpm`) and serve them from their own repository.

## 📖 Lesson 4.6 — Automatic security updates

`unattended-upgrades` installs security updates daily (enabled by default on Ubuntu servers and cloud images):
```bash
cat /etc/apt/apt.conf.d/20auto-upgrades            # Update-Package-Lists "1"; Unattended-Upgrade "1";
sudo unattended-upgrade --dry-run --debug | tail   # what it would do
ls /var/run/reboot-required 2>/dev/null && echo "a reboot is needed (kernel/libc update)"
```
Decide how reboots happen (a maintenance window, `Unattended-Upgrade::Automatic-Reboot`, or rebuilding images).

## 📖 Lesson 4.7 — Other ways software arrives

| Way | Notes |
|-----|-------|
| **snap** | sandboxed, self-updating packages (`snap list`); common on Ubuntu desktops, some server tools (e.g. Multipass) |
| **Tarballs / single binaries** | many DevOps tools (terraform, kubectl): download, **verify the checksum**, put in `/usr/local/bin` |
| **Language managers** | `pip` (in a venv!), `npm`, `go install` — never `sudo pip install` into the system Python |
| **RPM world** | RHEL/Rocky/Fedora: `dnf install/remove/search/info`, `rpm -qf FILE`, `rpm -ql PKG`, repos in `/etc/yum.repos.d/` |

---

## ⚠️ Common mistakes
- `apt upgrade` without `apt update` first (nothing new to install)
- `apt-key add` or `[trusted=yes]` repos; piping random install scripts from the internet into `sudo bash`
- Purging packages without checking what `autoremove` will take with them
- `sudo pip install` breaking system tools; installing by hand into `/usr/bin`
- Forgetting that held packages also miss **security** updates

---

## 🧪 Labs
On your lab VM. Reference solution: [`solutions/labs.sh`](solutions/labs.sh). Check: `sudo lab/check.sh 04`.

### Lab 1 ⭐ — Install and inspect
Install `tree` and `jq`. Which files did `tree` install? Which package owns `/usr/bin/curl`? Which repository does
`jq` come from, and is an upgrade waiting? Then **hold** `tree`.

### Lab 2 ⭐⭐ — Your first package
Copy [`hello-lab-src/`](hello-lab-src/) to `hello-lab_1.0.0_all`, set the version in `DEBIAN/control` to `1.0.0`,
build it with `dpkg-deb`, install it with `apt`, and prove `dpkg -S /usr/bin/hello-lab` knows its owner. Bonus:
build `1.0.1` with a changed message and upgrade to it.

### Lab 3 ⭐ — Patched automatically
Make sure `unattended-upgrades` is installed and enabled (`APT::Periodic::Unattended-Upgrade "1"`). Run a dry run
and read what it would do.

### Lab 4 ⭐⭐ — Read a repository
Open the `.sources` files in `/etc/apt/sources.list.d/`. Which suites and components are enabled? Find the
`Signed-By` keyring. Explain why `signed-by` is safer than `apt-key`.

---

## ✅ Checkpoint
- [ ] I can install, upgrade, remove, purge and inspect packages, and know apt vs apt-get vs dpkg
- [ ] I can add a third-party repository with its own signing key
- [ ] I can hold and pin versions and know the trade-off
- [ ] I've built and installed my own .deb
- [ ] My servers install security updates automatically
- [ ] `sudo lab/check.sh 04` passes

👉 Next: [Module 05 — Services, Boot & Time](../05-services-boot-time/README.md)
