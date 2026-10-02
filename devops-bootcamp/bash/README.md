# 🐚 Phase 2: Shell Script & Bash for DevOps

> **Shell** = the program that reads your commands (sh, bash, zsh, dash...).
> **Shell script** = a file of commands the shell runs.
> **Bash** = the most common shell on Linux servers, with extra features beyond plain POSIX `sh`.
>
> We start with commands that work in any shell and progressively use Bash-only features.
> Module 12 teaches you exactly what's Bash-only and how to write portable `sh` scripts
> (important for Alpine Docker images and minimal systems).

## Modules

| # | Module | Level |
|---|--------|-------|
| 01 | [Linux Terminal Essentials](01-terminal-essentials/README.md) | 🟢 Beginner |
| 02 | [Your First Script](02-first-script/README.md) | 🟢 Beginner |
| 03 | [Variables, Input & Arguments](03-variables-input-args/README.md) | 🟢 Beginner |
| 04 | [Conditionals](04-conditionals/README.md) | 🟢 Beginner |
| 05 | [Loops](05-loops/README.md) | 🟢 Beginner |
| 06 | [Functions](06-functions/README.md) | 🟡 Intermediate |
| 07 | [Arrays & String Manipulation](07-arrays-and-strings/README.md) | 🟡 Intermediate |
| 08 | [Text Processing: pipes, grep, sed, awk](08-text-processing/README.md) | 🟡 Intermediate |
| 09 | [Error Handling & Debugging](09-error-handling/README.md) | 🟡 Intermediate |
| 10 | [Processes & Scheduling](10-processes-and-scheduling/README.md) | 🔴 Pro |
| 11 | [Real DevOps Scripts](11-devops-scripts/README.md) | 🔴 Pro |
| 12 | [Pro Bash: getopts, ShellCheck, portability](12-pro-bash/README.md) | 🔴 Pro |
| 13 | [Capstone Projects](13-capstone/README.md) | 🏆 Capstone |

## Run any solution

```bash
cd devops-bootcamp/bash/04-conditionals/solutions
bash lab1_disk_check.sh        # or: chmod +x *.sh && ./lab1_disk_check.sh
```

## Install ShellCheck now (your Bash spell-checker)

```bash
sudo apt install -y shellcheck     # Ubuntu/Debian/WSL
brew install shellcheck            # macOS
shellcheck myscript.sh             # run it on EVERY script you write
```

## Bash cheat sheet

```bash
#!/usr/bin/env bash
set -euo pipefail                      # strict mode (Module 09)

name="web-01"                          # NO spaces around =
echo "Host: ${name}"                   # ALWAYS quote variables
today=$(date +%F)                      # command substitution
count=$(( 5 + 3 ))                     # arithmetic

echo "$1 $2 $# $@ $?"                  # args, arg count, all args, last exit code

if [[ -f /etc/hosts && $count -gt 5 ]]; then echo yes; elif ...; else ...; fi
case "$cmd" in start) ...;; stop|halt) ...;; *) ...;; esac

for s in web-01 web-02; do echo "$s"; done
for ((i=0; i<5; i++)); do echo "$i"; done
while read -r line; do echo "$line"; done < file.txt

greet() { local who="$1"; echo "hi $who"; }
servers=(web-01 web-02); echo "${servers[@]}" "${#servers[@]}"

cmd > out.txt 2>&1        cmd | grep x | sort | uniq -c        cmd1 && cmd2 || cmd3
```
