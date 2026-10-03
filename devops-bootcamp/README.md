# 🚀 DevOps Bootcamp: Python → Shell → Bash → Docker → Kubernetes → Terraform → Ansible

> **From your CEO / Senior DevOps Engineer:**
> Welcome to the team. In DevOps we automate *everything*: servers, deployments, backups,
> monitoring, cloud. First you learn the three scripting tools you'll use **every day**:
>
> - **Python** — powerful automation, APIs, cloud, data
> - **Shell scripting (POSIX `sh`)** — the universal language of every Linux/Unix system and Docker image
> - **Bash** — the most popular shell, with extra power for serious server automation
>
> Then the four platform tools every DevOps job asks for:
>
> - **Docker** — package any app into an image that runs the same everywhere
> - **Kubernetes** — run containers at scale: self-healing, rolling updates, autoscaling
> - **Terraform** — create infrastructure (cloud, clusters) from reviewed code
> - **Ansible** — configure servers and deploy apps, idempotently, over SSH
>
> This bootcamp takes you from zero to the level I expect from engineers on my team.
> Everything is designed and tested for **Ubuntu**.
>
> **My rules:** Read → type every example yourself (no copy-paste) → do the labs →
> only then look at the solution.

---

## 📅 Learn every day: the Daily Plan

The whole course is laid out as **180 days** (about 6 months) of 60–90 minutes, in [**DAILY-PLAN.md**](DAILY-PLAN.md).
Every day = 🔁 10-min warm-up on older material + 📖 lessons + 🧪 labs + 💾 commit.
Every 7th day is a review day. Your terminal tells you what to do today:

```bash
cd ~/Practice/devops-bootcamp
sh today.sh          # today's task
sh today.sh done     # mark it complete → see tomorrow
sh today.sh status   # progress bar
```

## 🗺️ The Roadmap — follow it in order

```
 STEP 0           PHASE 1              PHASE 2                  PHASE 3
 ┌─────────┐      ┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
 │ Ubuntu  │ ───► │   PYTHON     │ ──► │ SHELL SCRIPTING  │ ──► │    BASH      │
 │ setup   │      │ 15 modules   │     │ (POSIX sh)       │     │  8 modules   │
 │ Day 1   │      │ Days 2–44    │     │ 10 modules       │     │ Days 71–96   │
 └─────────┘      └──────────────┘     │ Days 45–70       │     └──────┬───────┘
                                       └──────────────────┘            │
        ┌──────────────────────────────────────────────────────────────┘
        ▼
 PHASE 4            PHASE 5              PHASE 6              PHASE 7
 ┌──────────────┐   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
 │   DOCKER     │─► │  KUBERNETES  │ ──► │  TERRAFORM   │ ──► │   ANSIBLE    │
 │  7 modules   │   │ 10 modules   │     │ 10 modules   │     │  8 modules   │
 │ Days 97–115  │   │ Days 116–137 │     │ Days 138–159 │     │ Days 160–180 │
 └──────────────┘   └──────────────┘     └──────────────┘     └──────────────┘
   (Day 97: setup part 2 — install the DevOps tools)
```

One app — **demo-app** — travels through Phases 4–7: you containerise it, run it on Kubernetes, describe its
platform in Terraform, and deploy it to Linux servers with Ansible. By the end you've shipped the same service
four professional ways.

| Step | Track | What it covers |
|------|-------|----------------|
| **0** | [🐧 Ubuntu Setup](00-ubuntu-setup/README.md) | Install tools, Python venv, editor, Git, check script — and [part 2](00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md) (Docker, kubectl, kind, Helm, Terraform, Ansible) |
| **1** | [🐍 Python](1-python/README.md) | 15 modules: basics → automation → APIs/cloud → testing → advanced → capstone |
| **2** | [🐚 Shell Scripting (POSIX sh)](2-shell-scripting/README.md) | 10 modules: terminal → scripts → loops → grep/sed/awk → errors → cron → capstone |
| **3** | [💪 Bash](3-bash/README.md) | 8 modules: Bash features → arrays → strict mode → SSH & fleets → real DevOps scripts → pro → capstone |
| **4** | [🐳 Docker](4-docker/README.md) | 7 modules: containers → images → Dockerfiles → volumes & networks → Compose → production images → capstone |
| **5** | [☸️ Kubernetes](5-kubernetes/README.md) | 10 modules: kind cluster → pods → deployments → services & ingress → config → storage → autoscaling → Helm → security → capstone |
| **6** | [🏗️ Terraform](6-terraform/README.md) | 10 modules: first config → resources → variables → state → loops → modules → Kubernetes → AWS (optional) → testing & CI → capstone |
| **7** | [⚙️ Ansible](7-ansible/README.md) | 8 modules: inventory → playbooks → variables → templates → roles → vault → testing → capstone |

### Shell scripting vs Bash — why are they separate?

- **Shell scripting (POSIX `sh`)** is the **standard** core every shell understands. Scripts start with
  `#!/bin/sh` and run anywhere — including tiny Alpine Docker images that don't have Bash.
  On Ubuntu, `sh` is `dash`.
- **Bash** understands everything in POSIX `sh` **plus** many extras (`[[ ]]`, arrays, `(( ))`,
  `pipefail`, `trap ERR`...). Scripts start with `#!/usr/bin/env bash`.

Learn the core first (Phase 2), then the extras (Phase 3). You'll always know **which** features
are portable and which aren't — that's a senior-engineer skill.

---

## 🐍 Phase 1 — Python → [`1-python/`](1-python/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Getting Started](1-python/01-getting-started/README.md) | 🟢 |
| 02 | [Variables, Types & Operators](1-python/02-variables-and-types/README.md) | 🟢 |
| 03 | [Strings](1-python/03-strings/README.md) | 🟢 |
| 04 | [Control Flow](1-python/04-control-flow/README.md) | 🟢 |
| 05 | [Data Structures](1-python/05-data-structures/README.md) | 🟢 |
| 06 | [Functions](1-python/06-functions/README.md) | 🟡 |
| 07 | [Files & Error Handling](1-python/07-files-and-errors/README.md) | 🟡 |
| 08 | [Modules, venv & pip](1-python/08-modules-venv-pip/README.md) | 🟡 |
| 09 | [Object-Oriented Python](1-python/09-oop/README.md) | 🟡 |
| 10 | [System Automation](1-python/10-system-automation/README.md) | 🔴 |
| 11 | [Data Formats & Regex](1-python/11-data-formats/README.md) | 🔴 |
| 12 | [APIs & Cloud](1-python/12-apis-and-cloud/README.md) | 🔴 |
| 13 | [Testing & Code Quality](1-python/13-testing-and-quality/README.md) | 🔴 |
| 14 | [Advanced Python](1-python/14-advanced-python/README.md) | 🔴 |
| 15 | [Capstone Projects](1-python/15-capstone/README.md) | 🏆 |

## 🐚 Phase 2 — Shell Scripting (POSIX sh) → [`2-shell-scripting/`](2-shell-scripting/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Linux Terminal Essentials](2-shell-scripting/01-terminal-essentials/README.md) | 🟢 |
| 02 | [Your First Shell Script](2-shell-scripting/02-first-script/README.md) | 🟢 |
| 03 | [Variables, Input & Arguments](2-shell-scripting/03-variables-input-args/README.md) | 🟢 |
| 04 | [Conditionals](2-shell-scripting/04-conditionals/README.md) | 🟢 |
| 05 | [Loops](2-shell-scripting/05-loops/README.md) | 🟢 |
| 06 | [Functions](2-shell-scripting/06-functions/README.md) | 🟡 |
| 07 | [Pipes & Text Processing](2-shell-scripting/07-pipes-and-text-processing/README.md) | 🟡 |
| 08 | [Exit Codes & Errors](2-shell-scripting/08-exit-codes-and-errors/README.md) | 🟡 |
| 09 | [Processes & Scheduling](2-shell-scripting/09-processes-and-scheduling/README.md) | 🔴 |
| 10 | [Shell Capstone](2-shell-scripting/10-capstone/README.md) | 🏆 |

## 💪 Phase 3 — Bash → [`3-bash/`](3-bash/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [From sh to Bash](3-bash/01-from-sh-to-bash/README.md) | 🟡 |
| 02 | [Arrays & String Manipulation](3-bash/02-arrays-and-strings/README.md) | 🟡 |
| 03 | [Functions & Libraries](3-bash/03-functions-and-libraries/README.md) | 🟡 |
| 04 | [Strict Mode & Debugging](3-bash/04-strict-mode-and-debugging/README.md) | 🔴 |
| 05 | [Remote Servers: SSH, scp & rsync](3-bash/05-remote-servers-ssh/README.md) | 🔴 |
| 06 | [Real DevOps Scripts](3-bash/06-real-devops-scripts/README.md) | 🔴 |
| 07 | [Pro Bash](3-bash/07-pro-bash/README.md) | 🔴 |
| 08 | [Bash Capstone](3-bash/08-capstone/README.md) | 🏆 |

## 🐳 Phase 4 — Docker → [`4-docker/`](4-docker/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Containers & Your First `docker run`](4-docker/01-containers-and-setup/README.md) | 🟢 |
| 02 | [Images & Registries](4-docker/02-images-and-registries/README.md) | 🟢 |
| 03 | [Writing Dockerfiles](4-docker/03-dockerfile/README.md) | 🟡 |
| 04 | [Volumes & Networking](4-docker/04-volumes-and-networking/README.md) | 🟡 |
| 05 | [Docker Compose](4-docker/05-docker-compose/README.md) | 🟡 |
| 06 | [Production-ready Images](4-docker/06-production-images/README.md) | 🔴 |
| 07 | [Docker Capstone](4-docker/07-capstone/README.md) | 🏆 |

## ☸️ Phase 5 — Kubernetes → [`5-kubernetes/`](5-kubernetes/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Concepts & Your Local Cluster](5-kubernetes/01-concepts-and-cluster/README.md) | 🟢 |
| 02 | [Pods & kubectl](5-kubernetes/02-pods-and-kubectl/README.md) | 🟢 |
| 03 | [Deployments & Rollouts](5-kubernetes/03-deployments-and-rollouts/README.md) | 🟡 |
| 04 | [Services & Ingress](5-kubernetes/04-services-and-ingress/README.md) | 🟡 |
| 05 | [ConfigMaps & Secrets](5-kubernetes/05-configmaps-and-secrets/README.md) | 🟡 |
| 06 | [Storage & StatefulSets](5-kubernetes/06-storage-and-statefulsets/README.md) | 🔴 |
| 07 | [Probes, Resources & Autoscaling](5-kubernetes/07-probes-resources-autoscaling/README.md) | 🔴 |
| 08 | [Helm & Kustomize](5-kubernetes/08-helm-and-kustomize/README.md) | 🔴 |
| 09 | [Troubleshooting & Security](5-kubernetes/09-troubleshooting-and-security/README.md) | 🔴 |
| 10 | [Kubernetes Capstone](5-kubernetes/10-capstone/README.md) | 🏆 |

## 🏗️ Phase 6 — Terraform → [`6-terraform/`](6-terraform/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [IaC & Your First Config](6-terraform/01-iac-and-first-config/README.md) | 🟢 |
| 02 | [Resources & Dependencies](6-terraform/02-resources-and-dependencies/README.md) | 🟢 |
| 03 | [Variables, Outputs & Locals](6-terraform/03-variables-outputs-locals/README.md) | 🟡 |
| 04 | [State](6-terraform/04-state/README.md) | 🟡 |
| 05 | [Expressions, Loops & Functions](6-terraform/05-expressions-and-loops/README.md) | 🔴 |
| 06 | [Modules](6-terraform/06-modules/README.md) | 🔴 |
| 07 | [Terraform + Kubernetes](6-terraform/07-kubernetes-with-terraform/README.md) | 🔴 |
| 08 | [Terraform on AWS (optional)](6-terraform/08-aws-with-terraform/README.md) | 🔴 |
| 09 | [Workflow, Testing & CI](6-terraform/09-workflow-testing-ci/README.md) | 🔴 |
| 10 | [Terraform Capstone](6-terraform/10-capstone/README.md) | 🏆 |

## ⚙️ Phase 7 — Ansible → [`7-ansible/`](7-ansible/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Inventory & Ad-hoc Commands](7-ansible/01-inventory-and-adhoc/README.md) | 🟢 |
| 02 | [Playbooks](7-ansible/02-playbooks/README.md) | 🟢 |
| 03 | [Variables, Facts, Conditionals & Loops](7-ansible/03-variables-facts-loops/README.md) | 🟡 |
| 04 | [Templates & Handlers](7-ansible/04-templates-and-handlers/README.md) | 🟡 |
| 05 | [Roles & Collections](7-ansible/05-roles-and-collections/README.md) | 🔴 |
| 06 | [Vault & Secrets](7-ansible/06-vault-and-secrets/README.md) | 🔴 |
| 07 | [Testing & Quality](7-ansible/07-testing-and-quality/README.md) | 🔴 |
| 08 | [Ansible Capstone](7-ansible/08-capstone/README.md) | 🏆 |

---

## 📚 Every module has the same structure

```
NN-module-name/
├── README.md      ← the lesson + labs
├── data/          ← sample files for the labs (some modules)
└── solutions/     ← reference answers — open ONLY after you've tried!
```

Inside each `README.md`, in this order:

1. **🎯 Objectives** — what you'll be able to do
2. **🧠 Why DevOps engineers care** — the real-world reason
3. **📖 Lessons** — short explanations + examples you type and run
4. **⚠️ Common mistakes** — what trips up beginners
5. **🧪 Labs** — practice from ⭐ easy to ⭐⭐⭐ hard
6. **✅ Checkpoint** — tick every box before moving on

## 🔁 Your daily study routine (step by step)

1. Open the terminal: `cd ~/Practice/devops-bootcamp`
2. Make sure your Python venv is on (prompt starts with `(devops)`) — see [Step 0](00-ubuntu-setup/README.md#step-5--create-a-python-virtual-environment-important-on-ubuntu)
3. Run `sh today.sh` and follow the 4 steps it shows (warm-up → learn → practice → save)
4. Run `sh today.sh done`, then `git add -A && git commit -m "Day N" && git push`

Missed a day? Continue where you stopped — never skip ahead.

**Expert checklists** (your final exams): [Python](1-python/README.md#-python-expert-checklist) ·
[Shell](2-shell-scripting/README.md#-shell-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes) ·
[Bash](3-bash/README.md#-bash-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes) ·
[Docker](4-docker/README.md#-docker-expert-checklist) ·
[Kubernetes](5-kubernetes/README.md#-kubernetes-expert-checklist) ·
[Terraform](6-terraform/README.md#-terraform-expert-checklist) ·
[Ansible](7-ansible/README.md#-ansible-expert-checklist)

---

## 🧭 Which one do I use at work?

| Use **POSIX sh** when… | Use **Bash** when… | Use **Python** when… |
|------------------------|--------------------|----------------------|
| Docker entrypoints (Alpine) | Server automation scripts | Logic gets complex (> ~150 lines) |
| Installers (`curl ... \| sh`) | CI/CD pipeline steps | Talking to APIs (AWS, GitHub, Slack) |
| Must run on any Unix | Gluing Linux commands with arrays/strict mode | Parsing JSON/YAML seriously |
| Git hooks shared by a team | Cron jobs, deploy scripts | You need tests, classes, libraries |

A senior engineer knows **all three** and picks the right one.

And for the platform tools:

| Use **Docker** to… | Use **Kubernetes** to… | Use **Terraform** to… | Use **Ansible** to… |
|--------------------|------------------------|-----------------------|---------------------|
| package an app + its dependencies | run many containers reliably | **create** infrastructure via APIs | **configure** what's inside servers |
| get the same build everywhere | self-heal, roll out, autoscale | keep state, plan before changing | install, template, restart, patch |
| run local dev stacks (Compose) | expose apps (Services, Ingress) | build VPCs, clusters, buckets, DNS | deploy to VMs and bare metal |

👉 **Start now:** [Step 0 — Set up your Ubuntu lab](00-ubuntu-setup/README.md)
