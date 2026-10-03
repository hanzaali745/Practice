# Step 0 · Part 3 — Install the Platform Tools 🔁📈🔎☁️

> **Do this after you finish Phase 7 — Ansible (Day 180), before Phase 8 — CI/CD.**
> Takes about 30 minutes. Everything here is for **Ubuntu 22.04 / 24.04**, on top of
> [Part 1](README.md) and [Part 2](PART-2-DEVOPS-TOOLS.md).

## What you need

| Resource | Minimum | Recommended | Why |
|----------|---------|-------------|-----|
| RAM | 8 GB | 16 GB | the ELK stack (Phase 10) wants ~4 GB on its own |
| Free disk | 20 GB | 40 GB | Elasticsearch, Prometheus and CI runner images are big |
| Accounts | a GitHub account | + an AWS account (Phase 11) | everything else is local and free |

## Step 1 — GitHub CLI (`gh`)

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh
gh auth login            # GitHub.com → SSH → log in with a web browser
```

## Step 2 — `act` and `actionlint` (run and check GitHub Actions locally)

```bash
# act — runs your workflows in Docker on your laptop
curl -sSfL https://github.com/nektos/act/releases/download/v0.2.89/act_Linux_x86_64.tar.gz \
  | sudo tar -xz -C /usr/local/bin act
act --version

# actionlint — finds mistakes in workflow files before you push
curl -sSfL https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz \
  | sudo tar -xz -C /usr/local/bin actionlint
actionlint --version

# the image act uses to imitate GitHub's ubuntu-latest runner (~2 GB, download once)
docker pull catthehacker/ubuntu:act-24.04
```

## Step 3 — Python packages for Phases 8–11

```bash
source ~/venvs/devops/bin/activate
cd ~/Practice/devops-bootcamp
pip install -r requirements-platform.txt     # zizmor, prometheus-client, boto3, moto, git-filter-repo, pre-commit
```

## Step 4 — AWS CLI v2 (official installer)

```bash
cd /tmp
curl -sSfL -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip -q awscliv2.zip && sudo ./aws/install --update
rm -rf awscliv2.zip aws
aws --version                                 # aws-cli/2.x
```
(If you installed the snap in Part 2, that's fine too — keep one of them.) Don't configure credentials yet:
Phase 11, Module 01 starts with account safety.

## Step 5 — A kernel setting for Elasticsearch

Elasticsearch needs more memory-mapped areas than Ubuntu allows by default:
```bash
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-elasticsearch.conf
sudo sysctl --system | grep max_map_count
```

## Step 6 — Check everything

```bash
cd ~/Practice/devops-bootcamp
sh 00-ubuntu-setup/check_platform_tools.sh
```
```
== CI/CD ==
✅ gh installed
✅ gh is logged in
✅ act installed
...
🎉 All good — start Phase 8: 8-cicd/01-cicd-concepts-and-first-workflow/README.md
```

👉 Next: [Phase 8 — CI/CD](../8-cicd/README.md)
