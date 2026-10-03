#!/usr/bin/env bash
# new-vm.sh [--delete] — a throw-away Ubuntu 24.04 VM for the Linux-admin labs, with this course mounted inside.
#   ./new-vm.sh            create "linuxlab" (2 CPUs, 2 GB RAM, 15 GB disk) and mount ~/Practice into it
#   multipass shell linuxlab
#   ./new-vm.sh --delete   throw it away (then create a fresh one any time)
# Needs Multipass: sudo snap install multipass   (macOS/Windows: https://multipass.run)
set -euo pipefail
vm=linuxlab
command -v multipass > /dev/null || { echo "install Multipass first: sudo snap install multipass" >&2; exit 1; }

if [[ ${1:-} == --delete ]]; then
    multipass delete --purge "$vm"
    echo "🗑️  $vm deleted"
    exit 0
fi

multipass launch 24.04 --name "$vm" --cpus 2 --memory 2G --disk 15G
course=$(cd "$(dirname "$0")/../../.." && pwd)            # ~/Practice
multipass mount "$course" "$vm:/home/ubuntu/Practice"
multipass exec "$vm" -- sudo apt-get update -qq
multipass exec "$vm" -- sudo apt-get install -y -qq acl lvm2 parted > /dev/null
cat <<EOF

✅ $vm is ready. Log in:   multipass shell $vm
   The course is at ~/Practice/devops-bootcamp inside the VM (shared with your machine, so your notes are saved).
   Break things freely — "./new-vm.sh --delete" and a new VM take two minutes.
EOF
