#!/usr/bin/env bash
# Module 04 labs — reference solution. Run: sudo ./labs.sh   (safe to run again)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

# Lab 1 — install, inspect, hold
apt-get update
apt-get install -y tree jq
dpkg -L tree | sed -n 1,5p                                   # which files did it install?
dpkg -S "$(command -v curl)"                             # which package owns this file?
apt-cache policy jq | sed -n 1,4p                            # installed vs candidate version, and from which repo
apt-mark hold tree                                       # never upgrade tree automatically
apt-mark showhold

# Lab 2 — build and install your own .deb
build=$(mktemp -d)
cp -a "$here/../hello-lab-src" "$build/hello-lab_1.0.0_all"
sed -i 's/^Version: .*/Version: 1.0.0/' "$build/hello-lab_1.0.0_all/DEBIAN/control"
dpkg-deb --build --root-owner-group "$build/hello-lab_1.0.0_all" > /dev/null
apt-get install -y "$build/hello-lab_1.0.0_all.deb"      # apt (not dpkg -i) also resolves dependencies
dpkg -s hello-lab | grep -E '^(Status|Version)'
dpkg -S /usr/bin/hello-lab
hello-lab
rm -rf "$build"

# Lab 3 — automatic security updates
apt-get install -y unattended-upgrades
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
apt-config dump | grep -E 'Periodic::(Update-Package-Lists|Unattended-Upgrade)'
