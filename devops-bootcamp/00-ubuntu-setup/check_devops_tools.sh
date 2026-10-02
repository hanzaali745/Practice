#!/bin/sh
# check_devops_tools.sh — verify the Phase 4-7 tools (Docker, Kubernetes, Terraform, Ansible).
# Usage: sh 00-ubuntu-setup/check_devops_tools.sh

failed=0

check() {
    desc="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        printf '✅ %s\n' "$desc"
    else
        printf '❌ %s\n' "$desc"
        failed=$((failed + 1))
    fi
}

echo "== Docker =="
check "docker installed"                    command -v docker
check "docker works without sudo"           docker info
check "docker compose plugin"               docker compose version

echo "== Kubernetes =="
check "kubectl installed"                   command -v kubectl
check "kind installed"                      command -v kind
check "helm installed"                      command -v helm

echo "== Terraform =="
check "terraform installed"                 command -v terraform

echo "== Ansible =="
check "virtual environment is active"       test -n "${VIRTUAL_ENV:-}"
check "ansible installed"                   command -v ansible
check "ansible-playbook installed"          command -v ansible-playbook
check "ansible-lint installed"              command -v ansible-lint

echo "== Machine =="
mem_gb=$(awk '/^MemTotal:/ { printf "%d", $2 / 1024 / 1024 }' /proc/meminfo)
check "at least 7 GB RAM (found ${mem_gb} GB)" test "$mem_gb" -ge 7
free_gb=$(df -P "$HOME" | awk 'NR == 2 { printf "%d", $4 / 1024 / 1024 }')
check "at least 20 GB free disk (found ${free_gb} GB)" test "$free_gb" -ge 20

echo
if [ "$failed" -eq 0 ]; then
    echo "🎉 All good — start Phase 4: 4-docker/01-containers-and-setup/README.md"
else
    echo "⚠️  $failed check(s) failed — see 00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md"
    exit 1
fi
