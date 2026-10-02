# 🚀 DevOps Scripting Bootcamp: Python → Shell Scripting → Bash

> **From your CEO / Senior DevOps Engineer:**
> Welcome to the team. In DevOps we automate *everything*: servers, deployments, backups,
> monitoring, cloud. You'll use three scripting tools **every day**:
>
> - **Python** — powerful automation, APIs, cloud, data
> - **Shell scripting (POSIX `sh`)** — the universal language of every Linux/Unix system and Docker image
> - **Bash** — the most popular shell, with extra power for serious server automation
>
> This bootcamp takes you from zero to the level I expect from engineers on my team.
> Everything is designed and tested for **Ubuntu**.
>
> **My rules:** Read → type every example yourself (no copy-paste) → do the labs →
> only then look at the solution.

---

## 🗺️ The Roadmap — follow it in order

```
 STEP 0           PHASE 1              PHASE 2                  PHASE 3
 ┌─────────┐      ┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
 │ Ubuntu  │ ───► │   PYTHON     │ ──► │ SHELL SCRIPTING  │ ──► │    BASH      │
 │ setup   │      │ 14 modules   │     │ (POSIX sh)       │     │  7 modules   │
 │ 30 min  │      │ weeks 1–7    │     │ 10 modules       │     │ weeks 11–13  │
 └─────────┘      └──────────────┘     │ weeks 8–10       │     └──────────────┘
                                       └──────────────────┘
```

| Step | Track | What it covers |
|------|-------|----------------|
| **0** | [🐧 Ubuntu Setup](00-ubuntu-setup/README.md) | Install tools, Python venv, editor, Git, check script |
| **1** | [🐍 Python](1-python/README.md) | 14 modules: basics → automation → APIs/cloud → testing → capstone |
| **2** | [🐚 Shell Scripting (POSIX sh)](2-shell-scripting/README.md) | 10 modules: terminal → scripts → loops → grep/sed/awk → errors → cron → capstone |
| **3** | [💪 Bash](3-bash/README.md) | 7 modules: Bash features → arrays → strict mode → real DevOps scripts → pro → capstone |

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
| 14 | [Capstone Projects](1-python/14-capstone/README.md) | 🏆 |

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
| 05 | [Real DevOps Scripts](3-bash/05-real-devops-scripts/README.md) | 🔴 |
| 06 | [Pro Bash](3-bash/06-pro-bash/README.md) | 🔴 |
| 07 | [Bash Capstone](3-bash/07-capstone/README.md) | 🏆 |

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

1. Open the terminal and go to the course: `cd ~/Practice/devops-bootcamp`
2. Make sure your Python venv is on (prompt starts with `(devops)`) — see [Step 0](00-ubuntu-setup/README.md#step-5--create-a-python-virtual-environment-important-on-ubuntu)
3. Open today's module `README.md` and read it once, top to bottom
4. Type every example yourself in the terminal
5. Do the labs in `my-work/python`, `my-work/shell` or `my-work/bash`
6. Compare with `solutions/` only after a real attempt
7. Tick the ✅ Checkpoint, then `git add`, `git commit`, `git push`

## 📅 Suggested schedule (1–2 hours a day)

| Week | Do |
|------|----|
| 0 | Step 0 — Ubuntu setup |
| 1 | Python 01–03 |
| 2 | Python 04–05 |
| 3 | Python 06–07 |
| 4 | Python 08–09 |
| 5 | Python 10–11 |
| 6 | Python 12–13 |
| 7 | Python 14 (capstone) |
| 8 | Shell 01–04 |
| 9 | Shell 05–08 |
| 10 | Shell 09–10 (capstone) |
| 11 | Bash 01–03 |
| 12 | Bash 04–05 |
| 13 | Bash 06–07 (capstone) |

## ✅ Progress tracker (copy into your notes)

**Step 0:** - [ ] Ubuntu setup done, `check_setup.sh` all ✅

**Python:** - [ ] 01 - [ ] 02 - [ ] 03 - [ ] 04 - [ ] 05 - [ ] 06 - [ ] 07 - [ ] 08 - [ ] 09 - [ ] 10 - [ ] 11 - [ ] 12 - [ ] 13 - [ ] 14

**Shell:** - [ ] 01 - [ ] 02 - [ ] 03 - [ ] 04 - [ ] 05 - [ ] 06 - [ ] 07 - [ ] 08 - [ ] 09 - [ ] 10

**Bash:** - [ ] 01 - [ ] 02 - [ ] 03 - [ ] 04 - [ ] 05 - [ ] 06 - [ ] 07

**Expert checklists:** - [ ] [Python](1-python/README.md#-python-expert-checklist) - [ ] [Shell](2-shell-scripting/README.md#-shell-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes) - [ ] [Bash](3-bash/README.md#-bash-expert-checklist-youre-expert-when-you-can-do-all-of-these-without-notes)

---

## 🧭 Which one do I use at work?

| Use **POSIX sh** when… | Use **Bash** when… | Use **Python** when… |
|------------------------|--------------------|----------------------|
| Docker entrypoints (Alpine) | Server automation scripts | Logic gets complex (> ~150 lines) |
| Installers (`curl ... \| sh`) | CI/CD pipeline steps | Talking to APIs (AWS, GitHub, Slack) |
| Must run on any Unix | Gluing Linux commands with arrays/strict mode | Parsing JSON/YAML seriously |
| Git hooks shared by a team | Cron jobs, deploy scripts | You need tests, classes, libraries |

A senior engineer knows **all three** and picks the right one.

👉 **Start now:** [Step 0 — Set up your Ubuntu lab](00-ubuntu-setup/README.md)
