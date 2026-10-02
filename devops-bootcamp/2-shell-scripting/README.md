# 🐚 Phase 2: Shell Scripting (POSIX `sh`)

> **Finish Phase 1 (Python) first.** Then come here. Phase 3 (Bash) builds on this phase.

## What is "shell scripting" and how is it different from Bash?

```
            ┌──────────────────────────────────────────┐
            │  BASH  (Phase 3)                          │
            │  extra power: [[ ]], arrays, (( )),       │
            │  ${var//x/y}, trap ERR, getopts tricks... │
            │   ┌──────────────────────────────────┐    │
            │   │  POSIX SHELL  (this phase)       │    │
            │   │  the universal core: variables,  │    │
            │   │  if/[ ], case, for/while, pipes, │    │
            │   │  functions, exit codes, grep/    │    │
            │   │  sed/awk, cron                   │    │
            │   └──────────────────────────────────┘    │
            └──────────────────────────────────────────┘
```

- **Shell** = the program that reads your commands. There are many: `sh`, `dash`, `bash`, `zsh`, `ash`.
- **POSIX `sh`** = the **standard** every Unix shell understands. A script written in POSIX `sh`
  runs **everywhere**: Ubuntu, Debian, Alpine Docker images, BusyBox, macOS, routers.
- **Bash** = the most popular shell. It understands everything in POSIX `sh` **plus** many extras.

On Ubuntu, try this:

```bash
ls -l /bin/sh        # /bin/sh -> dash   ← Ubuntu's sh is "dash", a strict POSIX shell
echo $0              # bash              ← your interactive terminal is bash
```

So in this phase, every script:
- starts with `#!/bin/sh`
- is run with `sh script.sh` (which uses `dash` on Ubuntu)
- is checked with `shellcheck -s sh script.sh`

If it works in `dash`, it works everywhere. **That's why we learn this first.**

> ⚠️ Typing examples in your Ubuntu terminal? Your terminal is Bash, which also accepts
> POSIX code, so everything here works there too. But to prove a **script** is pure POSIX,
> always run it with `sh script.sh`.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Linux Terminal Essentials](01-terminal-essentials/README.md) | 🟢 | navigate, manage files & permissions |
| 02 | [Your First Shell Script](02-first-script/README.md) | 🟢 | shebang, `chmod +x`, `printf`, exit codes |
| 03 | [Variables, Input & Arguments](03-variables-input-args/README.md) | 🟢 | `$1`, `$#`, `"$@"`, `read`, quoting |
| 04 | [Conditionals](04-conditionals/README.md) | 🟢 | `if`, `[ ]`, `case`, file tests |
| 05 | [Loops](05-loops/README.md) | 🟢 | `for`, `while`, reading files line by line |
| 06 | [Functions](06-functions/README.md) | 🟡 | reusable functions, return codes |
| 07 | [Pipes & Text Processing](07-pipes-and-text-processing/README.md) | 🟡 | `|`, `>`, `grep`, `sed`, `awk`, `sort`, `uniq` |
| 08 | [Exit Codes & Errors](08-exit-codes-and-errors/README.md) | 🟡 | `set -eu`, `trap`, `die`, safe scripts |
| 09 | [Processes & Scheduling](09-processes-and-scheduling/README.md) | 🔴 | jobs, signals, cron, systemd |
| 10 | [Shell Capstone](10-capstone/README.md) | 🏆 | portable tools you'd ship in a Docker image |

## How to run the solutions

```bash
cd ~/Practice/devops-bootcamp/2-shell-scripting/04-conditionals/solutions
sh disk_check.sh               # run with POSIX sh (dash)
shellcheck -s sh disk_check.sh # check it like a pro
```

## POSIX shell cheat sheet

```sh
#!/bin/sh
set -eu                                   # stop on errors and unset variables

name="web-01"                             # NO spaces around =
echo "Host: $name"                        # ALWAYS quote "$variables"
today=$(date +%F)                         # command substitution
count=$((count + 1))                      # arithmetic

echo "$1 $# $@ $?"                        # first arg, arg count, all args, last exit code

if [ -f /etc/hosts ] && [ "$count" -gt 5 ]; then echo yes; elif ...; else ...; fi
case "$cmd" in start) ... ;; stop|halt) ... ;; *) ... ;; esac

for s in web-01 web-02; do echo "$s"; done
while IFS= read -r line; do echo "$line"; done < file.txt

greet() { echo "hi $1"; }

cmd > out.txt 2>&1        cmd | grep x | sort | uniq -c        cmd1 && cmd2 || cmd3
```

## 🏅 Shell expert checklist (you're "expert" when you can do all of these without notes)

- [ ] Explain the difference between `sh`, `dash` and `bash`, and why `#!/bin/sh` scripts must avoid bashisms
- [ ] Always quote variables and explain what goes wrong when you don't
- [ ] Write `[ ]` tests for strings, numbers and files from memory
- [ ] Read a file line by line with `while IFS= read -r`
- [ ] Use `"$@"`, `shift`, and print a usage message to stderr with exit code 2
- [ ] Build a `grep | awk | sort | uniq -c | sort -rn | head` pipeline to answer a question about a log
- [ ] Use `set -eu`, `trap ... EXIT`, and exit codes correctly
- [ ] Write a cron line and know why cron jobs fail (PATH, env, relative paths)
- [ ] Write a Docker entrypoint script that works in Alpine
- [ ] Get zero warnings from `shellcheck -s sh`

👉 Start: [Module 01 — Linux Terminal Essentials](01-terminal-essentials/README.md)
