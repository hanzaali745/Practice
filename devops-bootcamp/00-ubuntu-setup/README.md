# Step 0 — Set Up Your Ubuntu Lab 🐧

> **Do this once, before Module 01.** Takes about 20–30 minutes.
> Everything in this course is tested on **Ubuntu 24.04 LTS** (22.04 works too).

---

## Step 1 — Get Ubuntu

Pick **one**:

| You have… | Do this |
|-----------|---------|
| Ubuntu installed already | Skip to Step 2 ✅ |
| Windows 10/11 | Install **WSL2**: open *PowerShell as Administrator* → `wsl --install -d Ubuntu-24.04` → reboot → open "Ubuntu" from the Start menu and create a username + password |
| Mac or any PC | Install [VirtualBox](https://www.virtualbox.org/) or [Multipass](https://multipass.run/) (`multipass launch 24.04 --name devops` then `multipass shell devops`) |
| No install wanted | A free-tier cloud VM (AWS EC2 / GCP / Azure) with Ubuntu 24.04, connect with `ssh` |

Open a terminal (`Ctrl+Alt+T` on Ubuntu desktop) and check:

```bash
lsb_release -a        # should say Ubuntu 22.04 or 24.04
```

## Step 2 — Update the system

```bash
sudo apt update && sudo apt upgrade -y
```

> `sudo` = run as administrator. It asks for **your** password (nothing shows while you type — that's normal).

## Step 3 — Install all the tools for this course

Copy this whole block into the terminal:

```bash
sudo apt install -y \
    python3 python3-pip python3-venv \
    git curl wget jq tree htop unzip \
    iputils-ping netcat-openbsd \
    shellcheck bats dos2unix bc \
    vim nano
```

| Tool | Used for |
|------|----------|
| `python3`, `python3-venv`, `python3-pip` | Phase 1 (Python) |
| `git` | saving your work |
| `curl`, `wget`, `jq` | web requests & JSON |
| `iputils-ping`, `netcat-openbsd` | `ping` and `nc` network checks (missing on minimal Ubuntu) |
| `shellcheck` | checks your shell scripts for bugs (like a spell-checker) |
| `bats` | testing shell scripts (Phase 3) |
| `dos2unix` | fixes Windows line endings |
| `tree`, `htop`, `bc` | viewing folders, processes, maths |

## Step 4 — Get this course onto your machine

```bash
cd ~
git clone https://github.com/hanzaali745/Practice.git
cd Practice/devops-bootcamp
ls
```

You should see `00-ubuntu-setup  1-python  2-shell-scripting  3-bash  README.md ...`

## Step 5 — Create a Python virtual environment (IMPORTANT on Ubuntu)

On Ubuntu 23.04+ this **fails**:

```bash
pip install requests
# error: externally-managed-environment   ← Ubuntu protects its own Python
```

The correct way is a **virtual environment** (venv) — a private Python just for your work.
We create **one venv for the whole course**:

```bash
python3 -m venv ~/venvs/devops                  # create it (once)
source ~/venvs/devops/bin/activate              # turn it on
pip install -r ~/Practice/devops-bootcamp/requirements.txt   # install course libraries
```

When it's on, your prompt starts with `(devops)`. Turn it off with `deactivate`.

Make it turn on automatically in every new terminal:

```bash
echo 'source ~/venvs/devops/bin/activate' >> ~/.bashrc
```

(You'll learn exactly what venvs are in Python Module 08.)

## Step 6 — Create your own work folder

```bash
mkdir -p ~/Practice/devops-bootcamp/my-work/{python,shell,bash}
```

👉 **Rule:** you write your lab answers in `my-work/`. Don't edit the `solutions/` folders.

## Step 7 — Pick an editor

- **Easiest:** [VS Code](https://code.visualstudio.com/) → install extensions **Python**, **ShellCheck**, **Bash IDE**.
  - On WSL: install VS Code on Windows, then in Ubuntu run `code .` inside the folder.
- **Terminal only:** `nano file.py` (save `Ctrl+O`, exit `Ctrl+X`). Learn `vim` later — you'll need it on servers.

## Step 8 — Check everything works

```bash
cd ~/Practice/devops-bootcamp
sh 00-ubuntu-setup/check_setup.sh
```

Every line should show ✅. If something shows ❌, re-run Step 3 or Step 5.

## Step 9 — Set up Git (so you can save your progress)

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

At the end of every study session:

```bash
cd ~/Practice
git add devops-bootcamp/my-work
git commit -m "Lab work: Python module 03"
git push
```

---

## 📅 Step 10 — Meet your daily plan

The course is a **323-day plan** ([DAILY-PLAN.md](../DAILY-PLAN.md)). Each day your terminal tells you what to do:

```bash
cd ~/Practice/devops-bootcamp
sh today.sh          # shows today's task (Day 1 = this setup guide!)
sh today.sh done     # when you finish a day
sh today.sh status   # your progress bar
```

Your progress is saved in `my-work/progress.log`, so commit it with your labs.
Mark Day 1 done now: `sh today.sh done` 🎉

## 🔁 Your study routine for EVERY module (follow this exactly)

1. **Read** the module `README.md` from top to bottom once.
2. **Type** every example yourself in the terminal (no copy-paste — your fingers need to learn).
3. **Break** something on purpose and read the error.
4. **Do the labs** in `my-work/`, in order ⭐ → ⭐⭐ → ⭐⭐⭐.
5. **Compare** with `solutions/` only after you've tried for real (at least 20 minutes on a lab).
6. **Tick** the ✅ Checkpoint. Can't tick everything? Re-do that lesson tomorrow.
7. **Commit** your work to Git.

> 💡 Stuck for more than 30 minutes? Read the error message bottom-up, search it,
> then peek at only the *first few lines* of the solution and try again.

👉 Ready? Run `sh today.sh` — Day 2 is [Python Module 01](../1-python/01-getting-started/README.md).

> 🐧 **Day 71** (before Linux administration) you'll create a throw-away practice VM with Multipass
> ([Phase 2B](../2b-linux-admin/README.md)).
> 🐳 **Later:** on Day 124 (before Docker) you'll do [Part 2 — Install the DevOps tools](PART-2-DEVOPS-TOOLS.md),
> and on Day 208 (before CI/CD) [Part 3 — Install the platform tools](PART-3-PLATFORM-TOOLS.md).
