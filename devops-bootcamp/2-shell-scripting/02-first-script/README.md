# Shell Module 02 — Your First Shell Script 🟢

## 🎯 Objectives
- Write a script with a **shebang** (`#!/bin/sh`)
- Make it executable and run it 3 different ways
- Print with `echo` and `printf`; use comments
- Capture command output with `$(...)`
- Understand exit codes (`$?`) and `&&` / `||`
- Put your own scripts on the `PATH`

## 🧠 Why DevOps engineers care
Every repeated task — setting up a server, a backup, a CI step — starts life as a shell
script. Dockerfile `RUN` lines are shell. CI pipeline steps are shell. Cloud-init (user-data) is shell.

---

## 📖 Lesson 2.1 — Hello script (step by step)

**Step 1.** Go to your work folder and create a file:
```bash
cd ~/Practice/devops-bootcamp/my-work/shell
nano hello.sh
```

**Step 2.** Type this, then save (`Ctrl+O`, `Enter`) and exit (`Ctrl+X`):
```sh
#!/bin/sh
# My first shell script
echo "Hello, DevOps!"
echo "Today is $(date +%A)"
```

**Step 3.** Run it:
```bash
sh hello.sh
```
```
Hello, DevOps!
Today is Monday
```

What each part means:
- `#!/bin/sh` — the **shebang**. Must be the very **first line**. Tells Linux which program runs this file.
  On Ubuntu, `/bin/sh` is `dash` (a fast, strict POSIX shell).
- `# ...` — a **comment**. Ignored by the shell. Write comments for humans.
- `$(date +%A)` — runs `date +%A` and puts its output into the text.

## 📖 Lesson 2.2 — Three ways to run a script

```bash
sh hello.sh            # 1. give the file to sh — no permissions needed

chmod +x hello.sh      # 2a. give it "execute" permission (once)
./hello.sh             # 2b. run it directly — Linux reads the shebang

. ./hello.sh           # 3. "source" it: run inside your CURRENT shell
```

- Why `./`? The current folder is **not** on the `PATH` (a security feature). `./` means "this folder".
- Sourcing (`.`) is used for files that set variables you want to keep, like `~/.profile`.

## 📖 Lesson 2.3 — `echo` vs `printf`

```sh
echo "Simple line"
echo "Two" "words"                         # Two words

printf "Hello\n"                           # \n = new line (printf does NOT add one for you)
printf "%s has %d CPUs\n" "web-01" 4       # %s = text, %d = whole number
printf "%-10s|%5s\n" "HOST" "CPU"          # %-10s = left-aligned in 10 chars, %5s = right-aligned
printf "%-10s|%5d\n" "web-01" 45
printf "%.1f%%\n" 73.456                   # 73.5%   (%% prints a literal %)
```

Output:
```
HOST      |  CPU
web-01    |   45
```

> 💡 **Use `printf` for anything formatted.** `echo -e` and `echo -n` behave differently
> in `dash` and `bash`, so in portable scripts they're unreliable. `printf` behaves the same everywhere.

## 📖 Lesson 2.4 — Command substitution `$(...)`

Run a command and use its output:

```sh
host=$(hostname)
kernel=$(uname -r)
files=$(ls | wc -l)
echo "Running on $host (kernel $kernel), $files files here"
```

You may see the old style with backticks: `` host=`hostname` ``. It still works, but use `$(...)` —
it's easier to read and can be nested.

## 📖 Lesson 2.5 — Exit codes

Every command finishes with an **exit code**: `0` = success, `1`–`255` = failure.
`$?` holds the exit code of the last command.

```sh
ls /etc > /dev/null
echo $?               # 0  → success
ls /nope 2> /dev/null
echo $?               # 2  → failure (> /dev/null throws output away)
```

Chain commands with exit codes:

```sh
mkdir -p build && cd build && echo "ready"              # && → run next ONLY if previous succeeded
ping -c1 -W1 10.0.0.99 > /dev/null || echo "host down"  # || → run next ONLY if previous failed
sudo apt update; sudo apt upgrade -y                    # ;  → run next no matter what
```

End your own script with an exit code:
```sh
exit 0      # success
exit 1      # failure
```

## 📖 Lesson 2.6 — Here documents (multi-line text)

```sh
cat <<EOF
=========================
 Server: $(hostname)
 User:   $USER
=========================
EOF
```

Use `<<'EOF'` (quoted) when you want the text **exactly as written**, without expanding `$` —
perfect for writing config files:

```sh
cat > /tmp/app.conf <<'EOF'
log_dir=$HOME/logs
EOF
cat /tmp/app.conf      # log_dir=$HOME/logs   ← $HOME was NOT replaced
```

> ⚠️ The closing `EOF` must be alone on its line, with no spaces before it.

## 📖 Lesson 2.7 — Put your scripts on the PATH (use them like real commands)

```bash
echo "$PATH"                      # the folders Linux searches for commands
mkdir -p ~/bin
cp hello.sh ~/bin/hello
chmod +x ~/bin/hello
```

On Ubuntu, `~/bin` is added to your PATH automatically by `~/.profile` **if it exists when you log in**.
Close the terminal, open a new one (or run `. ~/.profile`), then:
```bash
hello                             # works from any folder!
which hello                       # /home/<you>/bin/hello
```

## 📖 Lesson 2.8 — The script template (start every script from this)

```sh
#!/bin/sh
#
# name.sh — one line saying what it does
# Usage: sh name.sh [args]
#
set -eu    # -e: stop on errors   -u: stop on unset variables (Module 08 explains)

echo "do work here"
```

---

## ⚠️ Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgot `chmod +x` | `Permission denied` | `chmod +x script.sh` or run with `sh script.sh` |
| File edited on Windows | `/bin/sh^M: bad interpreter` | `dos2unix script.sh` |
| Shebang not on line 1 | script runs with the wrong shell | move `#!/bin/sh` to the very top |
| Space after `#!` is fine; space before `#!` is not | shebang ignored | nothing before `#!` |
| `echo -e` in an `sh` script | prints `-e` literally in dash | use `printf` |

---

## 🧪 Labs
Do these in `~/Practice/devops-bootcamp/my-work/shell/`.

### Lab 1 ⭐ — Hello server
Write `hello_server.sh` that prints a banner (using a here document) with: hostname, current user,
date and time, and uptime.

**Steps:** 1) create the file with the shebang 2) add `cat <<EOF ... EOF` 3) put `$(hostname)`,
`$(whoami)`, `$(date '+%Y-%m-%d %H:%M')`, `$(uptime -p)` inside 4) run with `sh hello_server.sh`.

### Lab 2 ⭐ — System report
Write `sysreport.sh` that prints OS name, kernel, uptime, disk usage of `/`, memory, and IP address,
aligned with `printf "%-10s %s\n"`.

**Hints:** `uname -r` · `uptime -p` · `df -h /` · `free -h` · `hostname -I` ·
OS name is in `/etc/os-release` (try `. /etc/os-release; echo "$PRETTY_NAME"`).

### Lab 3 ⭐⭐ — Exit code explorer
Write `exitcodes.sh` that runs `true`, `false`, `ls /`, `ls /nope`, `grep -q root /etc/passwd`,
`grep -q nobody-xyz /etc/passwd` and prints each with its exit code.

### Lab 4 ⭐⭐ — Install it
Copy `sysreport.sh` to `~/bin/sysreport`, make it executable, open a new terminal and run `sysreport` from `/tmp`.

### Lab 5 ⭐⭐ — Prove it's portable
Run your scripts with `sh`, `dash` and `bash`, and check them with `shellcheck -s sh`. Fix every warning.

---

## ✅ Checkpoint
- [ ] I know what `#!/bin/sh` does and that `sh` is `dash` on Ubuntu
- [ ] I can run a script 3 ways
- [ ] I use `printf` for formatted output
- [ ] I can use `$(...)`, `$?`, `&&`, `||`

👉 Next: [Module 03 — Variables, Input & Arguments](../03-variables-input-args/README.md)
