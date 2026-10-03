# 🚀 DevOps Bootcamp: Python → Shell → Linux → Bash → Docker → Kubernetes → Terraform → Ansible → CI/CD → Monitoring → ELK → AWS → Job-ready

> **From your CEO / Senior DevOps Engineer:**
> Welcome to the team. In DevOps we automate *everything*: servers, deployments, backups,
> monitoring, cloud. First you learn the three scripting tools you'll use **every day**:
>
> - **Python** — powerful automation, APIs, cloud, data
> - **Shell scripting (POSIX `sh`)** — the universal language of every Linux/Unix system and Docker image
> - **Bash** — the most popular shell, with extra power for serious server automation
>
> In between, **Linux administration**: users, permissions, packages, services, disks, the kernel, networking and
> security — running real servers, not just typing commands on them.
>
> Then the four platform tools every DevOps job asks for:
>
> - **Docker** — package any app into an image that runs the same everywhere
> - **Kubernetes** — run containers at scale: self-healing, rolling updates, autoscaling
> - **Terraform** — create infrastructure (cloud, clusters) from reviewed code
> - **Ansible** — configure servers and deploy apps, idempotently, over SSH
>
> And finally the practices that run it all in production:
>
> - **CI/CD** — every push tested, built, scanned, signed and deployed by a pipeline (GitHub Actions, GitOps)
> - **Monitoring** — Prometheus and Grafana: metrics, dashboards, alerts and SLOs
> - **Logging** — the ELK stack: structured logs, shipped, parsed, searched and kept for the right time
> - **AWS** — the cloud: IAM, networking, compute, containers, serverless — safely and cheaply
>
> And then you get **job-ready**: troubleshooting broken servers under pressure, Git in a team, incident response,
> and interview preparation.
>
> This bootcamp takes you from zero to the level I expect from engineers on my team.
> Everything is designed and tested for **Ubuntu**.
>
> **My rules:** Read → type every example yourself (no copy-paste) → do the labs →
> only then look at the solution.

---

## 📅 Learn every day: the Daily Plan

The whole course is laid out as **323 days** (about 11 months) of 60–90 minutes, in [**DAILY-PLAN.md**](DAILY-PLAN.md).
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
 STEP 0              PHASE 1             PHASE 2             PHASE 2B
 ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
 │ UBUNTU SETUP │─►  │    PYTHON    │─►  │SHELL (POSIX) │─►  │ LINUX ADMIN  │
 │              │    │  15 modules  │    │  10 modules  │    │  9 modules   │
 │    Day 1     │    │  Days 2–44   │    │  Days 45–70  │    │  Days 71–96  │
 └──────────────┘    └──────────────┘    └──────────────┘    └───────┬──────┘
        ┌────────────────────────────────────────────────────────────┘
        ▼
 PHASE 3             PHASE 4             PHASE 5             PHASE 6
 ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
 │     BASH     │─►  │    DOCKER    │─►  │  KUBERNETES  │─►  │  TERRAFORM   │
 │  8 modules   │    │  7 modules   │    │  10 modules  │    │  10 modules  │
 │ Days 97–123  │    │ Days 124–142 │    │ Days 143–164 │    │ Days 165–186 │
 └──────────────┘    └──────────────┘    └──────────────┘    └───────┬──────┘
   (Day 124: setup part 2 — install the DevOps tools)                │
        ┌────────────────────────────────────────────────────────────┘
        ▼
 PHASE 7             PHASE 8             PHASE 9             PHASE 10
 ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
 │   ANSIBLE    │─►  │    CI/CD     │─►  │  MONITORING  │─►  │ ELK LOGGING  │
 │  8 modules   │    │  8 modules   │    │  8 modules   │    │  7 modules   │
 │ Days 187–207 │    │ Days 208–228 │    │ Days 229–249 │    │ Days 250–266 │
 └──────────────┘    └──────────────┘    └──────────────┘    └───────┬──────┘
   (Day 208: setup part 3 — install the platform tools)              │
        ┌────────────────────────────────────────────────────────────┘
        ▼
 PHASE 11            PHASE 12
 ┌──────────────┐    ┌──────────────┐
 │     AWS      │─►  │  JOB-READY   │
 │  8 modules   │    │  5 modules   │
 │ Days 267–287 │    │ Days 288–323 │
 └──────────────┘    └──────────────┘
   Phase 12: Linux & network troubleshooting · Git for teams · incidents · interview prep
```

One app — **demo-app** — travels through Phases 4–11: you containerise it, run it on Kubernetes, describe its
platform in Terraform and deploy it to Linux servers with Ansible. Then a pipeline ships it on every push, Prometheus
and ELK watch it, and finally it runs on AWS — the same service, all the way to monitored production.

| Step | Track | What it covers |
|------|-------|----------------|
| **0** | [🐧 Ubuntu Setup](00-ubuntu-setup/README.md) | Install tools, Python venv, editor, Git, check script — [part 2](00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md) (Docker, kubectl, kind, Helm, Terraform, Ansible) and [part 3](00-ubuntu-setup/PART-3-PLATFORM-TOOLS.md) (gh, act, actionlint, AWS CLI) |
| **1** | [🐍 Python](1-python/README.md) | 15 modules: basics → automation → APIs/cloud → testing → advanced → capstone |
| **2** | [🐚 Shell Scripting (POSIX sh)](2-shell-scripting/README.md) | 10 modules: terminal → scripts → loops → grep/sed/awk → errors → cron → capstone |
| **2B** | [🐧 Linux Administration](2b-linux-admin/README.md) | 9 modules: filesystem → users & sudo → permissions → packages → services & boot → storage & LVM → kernel → networking & hardening → capstone |
| **3** | [💪 Bash](3-bash/README.md) | 8 modules: Bash features → arrays → strict mode → SSH & fleets → real DevOps scripts → pro → capstone |
| **4** | [🐳 Docker](4-docker/README.md) | 7 modules: containers → images → Dockerfiles → volumes & networks → Compose → production images → capstone |
| **5** | [☸️ Kubernetes](5-kubernetes/README.md) | 10 modules: kind cluster → pods → deployments → services & ingress → config → storage → autoscaling → Helm → security → capstone |
| **6** | [🏗️ Terraform](6-terraform/README.md) | 10 modules: first config → resources → variables → state → loops → modules → Kubernetes → AWS (optional) → testing & CI → capstone |
| **7** | [⚙️ Ansible](7-ansible/README.md) | 8 modules: inventory → playbooks → variables → templates → roles → vault → testing → capstone |
| **8** | [🔁 CI/CD](8-cicd/README.md) | 8 modules: first workflow → syntax → testing → images → security → reusable workflows → deployment & GitOps → capstone |
| **9** | [📈 Monitoring](9-monitoring/README.md) | 8 modules: first stack → Prometheus → PromQL → instrumenting → Grafana → alerting & SLOs → Kubernetes → capstone |
| **10** | [🔎 ELK Logging](10-elk/README.md) | 7 modules: logging basics → Elasticsearch → shipping & parsing → Kibana → operating ES → Kubernetes → capstone |
| **11** | [☁️ AWS](11-aws/README.md) | 8 modules: safe account → IAM → VPC → EC2 & ALB → storage → containers → serverless & CloudWatch → capstone |
| **12** | [💼 Job-ready](12-job-ready/README.md) | 5 modules: Linux troubleshooting → networking troubleshooting → Git for teams → incident practice → interview prep |

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

## 🐧 Phase 2B — Linux Administration → [`2b-linux-admin/`](2b-linux-admin/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [The Filesystem & Files](2b-linux-admin/01-filesystem-and-files/README.md) | 🟢 |
| 02 | [Users, Groups & sudo](2b-linux-admin/02-users-groups-sudo/README.md) | 🟢 |
| 03 | [Permissions in Depth](2b-linux-admin/03-permissions-in-depth/README.md) | 🟡 |
| 04 | [Packages & Software](2b-linux-admin/04-packages/README.md) | 🟡 |
| 05 | [Services, Boot & Time](2b-linux-admin/05-services-boot-time/README.md) | 🟡 |
| 06 | [Storage: Disks, File Systems & LVM](2b-linux-admin/06-storage/README.md) | 🔴 |
| 07 | [Processes, Resources & the Kernel](2b-linux-admin/07-processes-and-kernel/README.md) | 🔴 |
| 08 | [Networking & Server Hardening](2b-linux-admin/08-networking-and-hardening/README.md) | 🔴 |
| 09 | [Capstone: Build a Server](2b-linux-admin/09-capstone/README.md) | 🏆 |

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

## 🔁 Phase 8 — CI/CD → [`8-cicd/`](8-cicd/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [CI/CD Concepts & Your First Workflow](8-cicd/01-cicd-concepts-and-first-workflow/README.md) | 🟢 |
| 02 | [Workflow Syntax in Depth](8-cicd/02-workflow-syntax/README.md) | 🟢 |
| 03 | [Testing & Quality Gates in CI](8-cicd/03-testing-in-ci/README.md) | 🟡 |
| 04 | [Building & Publishing Images](8-cicd/04-building-images/README.md) | 🟡 |
| 05 | [Secrets, Environments & Pipeline Security](8-cicd/05-secrets-and-security/README.md) | 🔴 |
| 06 | [Reusable Workflows & Custom Actions](8-cicd/06-reusable-workflows-and-actions/README.md) | 🔴 |
| 07 | [Deployment Pipelines & GitOps](8-cicd/07-deployment-and-gitops/README.md) | 🔴 |
| 08 | [CI/CD Capstone](8-cicd/08-capstone/README.md) | 🏆 |

## 📈 Phase 9 — Monitoring → [`9-monitoring/`](9-monitoring/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Observability & Your First Stack](9-monitoring/01-observability-and-first-stack/README.md) | 🟢 |
| 02 | [Prometheus in Depth](9-monitoring/02-prometheus-in-depth/README.md) | 🟢 |
| 03 | [PromQL](9-monitoring/03-promql/README.md) | 🟡 |
| 04 | [Instrumenting Apps & Exporters](9-monitoring/04-instrumenting-and-exporters/README.md) | 🟡 |
| 05 | [Grafana Dashboards as Code](9-monitoring/05-grafana/README.md) | 🟡 |
| 06 | [Alerting & SLOs](9-monitoring/06-alerting-and-slos/README.md) | 🔴 |
| 07 | [Monitoring Kubernetes](9-monitoring/07-kubernetes-monitoring/README.md) | 🔴 |
| 08 | [Monitoring Capstone](9-monitoring/08-capstone/README.md) | 🏆 |

## 🔎 Phase 10 — ELK Logging → [`10-elk/`](10-elk/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Logging Fundamentals](10-elk/01-logging-fundamentals/README.md) | 🟢 |
| 02 | [Elasticsearch](10-elk/02-elasticsearch/README.md) | 🟢 |
| 03 | [Shipping & Parsing Logs](10-elk/03-shipping-and-parsing/README.md) | 🟡 |
| 04 | [Kibana](10-elk/04-kibana/README.md) | 🟡 |
| 05 | [Operating Elasticsearch](10-elk/05-operating-elasticsearch/README.md) | 🔴 |
| 06 | [Logging on Kubernetes](10-elk/06-kubernetes-logging/README.md) | 🔴 |
| 07 | [ELK Capstone](10-elk/07-capstone/README.md) | 🏆 |

## ☁️ Phase 11 — AWS → [`11-aws/`](11-aws/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Cloud Basics & a Safe Account](11-aws/01-cloud-and-account-setup/README.md) | 🟢 |
| 02 | [IAM](11-aws/02-iam/README.md) | 🟢 |
| 03 | [Networking: VPC](11-aws/03-networking-vpc/README.md) | 🟡 |
| 04 | [Compute: EC2, Auto Scaling & ALB](11-aws/04-compute/README.md) | 🟡 |
| 05 | [Storage & Databases](11-aws/05-storage-and-databases/README.md) | 🟡 |
| 06 | [Containers on AWS](11-aws/06-containers-on-aws/README.md) | 🔴 |
| 07 | [Serverless & Monitoring](11-aws/07-serverless-and-monitoring/README.md) | 🔴 |
| 08 | [AWS Capstone](11-aws/08-capstone/README.md) | 🏆 |

## 💼 Phase 12 — Job-ready → [`12-job-ready/`](12-job-ready/README.md)

| # | Module | Level |
|---|--------|-------|
| 01 | [Linux Troubleshooting](12-job-ready/01-linux-troubleshooting/README.md) | 🟡 |
| 02 | [Networking Troubleshooting](12-job-ready/02-networking-troubleshooting/README.md) | 🟡 |
| 03 | [Git for Teams](12-job-ready/03-git-for-teams/README.md) | 🟡 |
| 04 | [Incident Practice](12-job-ready/04-incident-practice/README.md) | 🔴 |
| 05 | [Interview Prep](12-job-ready/05-interview-prep/README.md) | 🏆 |

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
[Linux](2b-linux-admin/README.md#-linux-expert-checklist) ·
[Bash](3-bash/README.md#-bash-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes) ·
[Docker](4-docker/README.md#-docker-expert-checklist) ·
[Kubernetes](5-kubernetes/README.md#-kubernetes-expert-checklist) ·
[Terraform](6-terraform/README.md#-terraform-expert-checklist) ·
[Ansible](7-ansible/README.md#-ansible-expert-checklist) ·
[CI/CD](8-cicd/README.md#-cicd-expert-checklist) ·
[Monitoring](9-monitoring/README.md#-monitoring-expert-checklist) ·
[ELK](10-elk/README.md#-elk-expert-checklist) ·
[AWS](11-aws/README.md#-aws-expert-checklist) ·
[Job-ready](12-job-ready/README.md#-job-ready-expert-checklist)

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

And for running it in production:

| Use **CI/CD** to… | Use **Prometheus + Grafana** to… | Use **ELK** to… | Use **AWS** to… |
|-------------------|----------------------------------|-----------------|-----------------|
| test every change before it merges | know *that* something is wrong (metrics) | find out *exactly what* happened (logs) | rent servers, networks, databases on demand |
| build, scan and sign one image | alert on symptoms, track SLOs | search and aggregate events across servers | run containers and functions without servers |
| deploy the same digest to every environment | graph trends and capacity | keep logs as long as you must, and no longer | pay only for what you use — and turn it off |

👉 **Start now:** [Step 0 — Set up your Ubuntu lab](00-ubuntu-setup/README.md)
