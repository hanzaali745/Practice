# Step 0 · Part 2 — Install the DevOps Tools 🐳☸️🏗️🤖

> **Do this after you finish Phases 1–3 (Day 96), before Phase 4 — Docker.**
> Takes about 45 minutes. Everything here is for **Ubuntu 22.04 / 24.04**.

## What you need

| Resource | Minimum | Recommended | Why |
|----------|---------|-------------|-----|
| RAM | 8 GB | 16 GB | a local Kubernetes cluster (kind) runs inside Docker |
| Free disk | 20 GB | 40 GB | container images add up fast |
| CPU | 2 cores | 4 cores | |

> **Windows / WSL users:** enable systemd in WSL first — add `[boot]` / `systemd=true` to
> `/etc/wsl.conf`, then run `wsl --shutdown` in PowerShell and reopen Ubuntu. (Or install
> **Docker Desktop** for Windows and turn on "WSL integration" — then skip Step 1.)

---

## Step 1 — Docker Engine (official repository)

Ubuntu's own `docker.io` package is often old. Use Docker's official repository:

```bash
# 1. Add Docker's signing key
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 2. Add the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install Docker Engine + Buildx + Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Run docker without sudo (log out and back in afterwards, or run `newgrp docker`)
sudo usermod -aG docker "$USER"
newgrp docker

# 5. Test
docker run --rm hello-world
docker compose version
```

> 🔐 Being in the `docker` group is equivalent to root access on that machine. That's fine on your
> own lab machine; on shared servers it's a security decision.

## Step 2 — kubectl (the Kubernetes command line)

```bash
sudo apt-get install -y apt-transport-https gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl version --client

# Handy: tab completion + the `k` shortcut everyone uses
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
```

## Step 3 — kind (Kubernetes IN Docker — your local cluster)

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```
(ARM machine? use `kind-linux-arm64` instead.)

Quick test — create and delete a cluster:
```bash
kind create cluster --name test
kubectl get nodes          # STATUS should become Ready
kind delete cluster --name test
```

## Step 4 — Helm (the Kubernetes package manager)

```bash
sudo snap install helm --classic
helm version
```
No snap (some WSL setups)? Follow the "From Script" section on https://helm.sh/docs/intro/install/

## Step 5 — Terraform (HashiCorp's official repository)

```bash
wget -O- https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
terraform version
terraform -install-autocomplete      # then open a new terminal
```

> 💡 **OpenTofu** (`tofu`) is an open-source fork of Terraform with the same language. Everything
> you learn here works there too.

## Step 6 — Ansible (inside your course venv)

Ansible is Python, so it goes in the venv you made in Part 1:

```bash
source ~/venvs/devops/bin/activate
pip install -r ~/Practice/devops-bootcamp/requirements-devops.txt
ansible --version
ansible-lint --version
```

The `ansible` package includes the most-used **collections** (`community.general`,
`community.docker`, `ansible.posix`...), so you don't need to install them separately.

## Step 7 — Optional: AWS CLI (only for the optional cloud lessons)

```bash
sudo snap install aws-cli --classic
aws --version
```
Then follow [Terraform Module 08](../6-terraform/08-aws-with-terraform/README.md) for safe account setup
(billing alarm first!).

## Step 8 — Check everything

```bash
cd ~/Practice/devops-bootcamp
sh 00-ubuntu-setup/check_devops_tools.sh
```

All ✅? Run `sh today.sh` — the next day is [Docker Module 01](../4-docker/01-containers-and-setup/README.md). 🚀
