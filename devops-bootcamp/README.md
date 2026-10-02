# 🚀 DevOps Scripting Bootcamp: Python → Shell → Bash

> **From your CEO / Senior DevOps Engineer:**
> Welcome to the team. In DevOps, we automate *everything*: servers, deployments,
> backups, monitoring, cloud resources. The two tools you'll use **every single day**
> are **Python** (for powerful automation, APIs, cloud) and **Shell/Bash** (for gluing
> Linux systems together). This bootcamp takes you from zero to the level I expect
> from engineers on my team.
>
> My rules: **Read → Type the examples yourself (no copy-paste!) → Do the labs → Only then check the solution.**

---

## 🗺️ The Roadmap

```
 PHASE 1: PYTHON (weeks 1-7)                PHASE 2: SHELL & BASH (weeks 8-12)
 ┌──────────────────────────────┐           ┌──────────────────────────────┐
 │ 🟢 Beginner   Modules 01-05   │           │ 🟢 Beginner   Modules 01-05   │
 │ 🟡 Intermediate Modules 06-09 │   ───►    │ 🟡 Intermediate Modules 06-09 │
 │ 🔴 Pro (DevOps) Modules 10-13 │           │ 🔴 Pro (DevOps) Modules 10-12 │
 │ 🏆 Capstone   Module 14       │           │ 🏆 Capstone   Module 13       │
 └──────────────────────────────┘           └──────────────────────────────┘
```

### Phase 1 — Python 🐍 → [`python/`](python/README.md)

| # | Module | Level | What you'll be able to do |
|---|--------|-------|---------------------------|
| 01 | [Getting Started](python/01-getting-started/README.md) | 🟢 | Install Python, run scripts, use the REPL |
| 02 | [Variables, Types & Operators](python/02-variables-and-types/README.md) | 🟢 | Store and calculate data, read user input |
| 03 | [Strings](python/03-strings/README.md) | 🟢 | Format, slice, clean text (log lines!) |
| 04 | [Control Flow](python/04-control-flow/README.md) | 🟢 | Make decisions, loop over things |
| 05 | [Data Structures](python/05-data-structures/README.md) | 🟢 | Lists, tuples, dicts, sets — inventories & configs |
| 06 | [Functions](python/06-functions/README.md) | 🟡 | Write reusable, clean code |
| 07 | [Files & Error Handling](python/07-files-and-errors/README.md) | 🟡 | Read/write files, handle failures safely |
| 08 | [Modules, venv & pip](python/08-modules-venv-pip/README.md) | 🟡 | Organise code, manage dependencies |
| 09 | [Object-Oriented Python](python/09-oop/README.md) | 🟡 | Model servers, services and deployments as classes |
| 10 | [System Automation](python/10-system-automation/README.md) | 🔴 | `os`, `pathlib`, `subprocess`, `argparse`, `logging` |
| 11 | [Data Formats & Regex](python/11-data-formats/README.md) | 🔴 | JSON, YAML, CSV, regular expressions |
| 12 | [APIs & Cloud](python/12-apis-and-cloud/README.md) | 🔴 | REST APIs, `requests`, intro to AWS `boto3` |
| 13 | [Testing & Code Quality](python/13-testing-and-quality/README.md) | 🔴 | `pytest`, type hints, linting |
| 14 | [Capstone Projects](python/14-capstone/README.md) | 🏆 | Build real DevOps tools end-to-end |

### Phase 2 — Shell Script & Bash 🐚 → [`bash/`](bash/README.md)

| # | Module | Level | What you'll be able to do |
|---|--------|-------|---------------------------|
| 01 | [Linux Terminal Essentials](bash/01-terminal-essentials/README.md) | 🟢 | Navigate, manage files, permissions |
| 02 | [Your First Script](bash/02-first-script/README.md) | 🟢 | Shebang, `chmod +x`, running scripts |
| 03 | [Variables, Input & Arguments](bash/03-variables-input-args/README.md) | 🟢 | `$1`, `$@`, `read`, quoting |
| 04 | [Conditionals](bash/04-conditionals/README.md) | 🟢 | `if`, `[[ ]]`, `case`, file tests |
| 05 | [Loops](bash/05-loops/README.md) | 🟢 | `for`, `while`, `until`, reading files |
| 06 | [Functions](bash/06-functions/README.md) | 🟡 | Reusable functions, `local`, return values |
| 07 | [Arrays & String Manipulation](bash/07-arrays-and-strings/README.md) | 🟡 | Indexed/associative arrays, `${var//x/y}` |
| 08 | [Text Processing](bash/08-text-processing/README.md) | 🟡 | Pipes, redirection, `grep`, `sed`, `awk` |
| 09 | [Error Handling & Debugging](bash/09-error-handling/README.md) | 🟡 | Exit codes, `set -euo pipefail`, `trap` |
| 10 | [Processes & Scheduling](bash/10-processes-and-scheduling/README.md) | 🔴 | Jobs, signals, `cron`, `systemd` timers |
| 11 | [Real DevOps Scripts](bash/11-devops-scripts/README.md) | 🔴 | Backups, health checks, log rotation, deploys |
| 12 | [Pro Bash](bash/12-pro-bash/README.md) | 🔴 | `getopts`, ShellCheck, portability, style guide |
| 13 | [Capstone Projects](bash/13-capstone/README.md) | 🏆 | Production-grade automation toolkit |

---

## 📚 How every module is structured

Each module folder looks the same, so you always know where you are:

```
NN-module-name/
├── README.md      ← 1. Concepts explained simply  2. Worked examples  3. Labs
└── solutions/     ← Reference solutions (open ONLY after you've tried!)
```

Inside each `README.md`:

1. **🎯 Objectives** — what you'll know by the end
2. **🧠 Why DevOps engineers care** — the real-world reason
3. **📖 Lessons** — concepts + examples you type and run
4. **⚠️ Common mistakes** — the things that bite juniors
5. **🧪 Labs** — hands-on practice, from easy (⭐) to hard (⭐⭐⭐)
6. **✅ Checkpoint** — a self-check before you move on

---

## 🛠️ Your Lab Environment

You need a Linux-like terminal. Pick **one**:

| Your computer | Best option |
|---------------|-------------|
| Linux | You're ready. Open a terminal. |
| macOS | Terminal app works. Install Homebrew + `brew install bash python` |
| Windows | Install **WSL2** (`wsl --install` in PowerShell as Admin) → Ubuntu |
| Any (no install) | A free cloud VM (AWS/GCP/Azure free tier) or GitHub Codespaces |

Check your tools:

```bash
python3 --version   # want 3.10+
bash --version      # want 4.0+  (macOS ships 3.2 — upgrade with brew)
git --version
```

Clone this repo and work inside it:

```bash
git clone <this-repo-url>
cd Practice/devops-bootcamp
mkdir -p my-work          # ← do your lab work here
```

> 💡 **Tip:** Commit your lab work to Git every day. Your GitHub history becomes
> your DevOps portfolio. Recruiters look at it.

---

## 📅 Suggested Schedule (1–2 hours/day)

| Week | Focus |
|------|-------|
| 1 | Python 01–03 |
| 2 | Python 04–05 |
| 3 | Python 06–07 |
| 4 | Python 08–09 |
| 5 | Python 10–11 |
| 6 | Python 12–13 |
| 7 | Python 14 (Capstone) |
| 8 | Bash 01–03 |
| 9 | Bash 04–06 |
| 10 | Bash 07–09 |
| 11 | Bash 10–12 |
| 12 | Bash 13 (Capstone) |

---

## ✅ Progress Tracker

Copy this into your notes and tick as you go:

**Python**
- [ ] 01 Getting Started  - [ ] 02 Variables  - [ ] 03 Strings  - [ ] 04 Control Flow
- [ ] 05 Data Structures  - [ ] 06 Functions  - [ ] 07 Files & Errors
- [ ] 08 Modules & venv  - [ ] 09 OOP  - [ ] 10 System Automation
- [ ] 11 Data Formats  - [ ] 12 APIs & Cloud  - [ ] 13 Testing  - [ ] 14 Capstone

**Shell / Bash**
- [ ] 01 Terminal  - [ ] 02 First Script  - [ ] 03 Variables & Args  - [ ] 04 Conditionals
- [ ] 05 Loops  - [ ] 06 Functions  - [ ] 07 Arrays & Strings  - [ ] 08 Text Processing
- [ ] 09 Error Handling  - [ ] 10 Processes & Cron  - [ ] 11 DevOps Scripts
- [ ] 12 Pro Bash  - [ ] 13 Capstone

---

## 🧭 Python vs Bash — when do I use which?

| Use **Bash** when… | Use **Python** when… |
|--------------------|----------------------|
| Gluing Linux commands together | Logic gets complex (> ~100 lines) |
| Quick server setup / bootstrap | Talking to APIs (AWS, GitHub, Slack) |
| CI/CD pipeline steps | Parsing JSON/YAML seriously |
| Cron jobs, small wrappers | You need tests, classes, libraries |
| Inside Dockerfiles | Building a reusable CLI tool |

A senior engineer knows **both** and picks the right one. Let's begin. 👉 [Start Python Module 01](python/01-getting-started/README.md)
