# Module 02 — Your First Shell Script 🟢

## 🎯 Objectives
- Write a script with a **shebang**
- Make it executable and run it 3 different ways
- Use `echo`, `printf`, comments, and command substitution `$(...)`
- Understand exit codes (`$?`) and `&&` / `||`
- Put your scripts on the `PATH`

## 🧠 Why DevOps engineers care
Every repeated task — provisioning a server, running a backup, a CI step — starts life
as a shell script. Dockerfiles `RUN` shell. CI pipelines run shell. Cloud-init (user-data) is shell.

---

## 📖 Lesson 2.1 — Hello script

`hello.sh`:
```bash
#!/usr/bin/env bash
# My first Bash script
echo "Hello, DevOps!"
echo "Today is $(date +%A)"
```

- Line 1 `#!` = **shebang**: tells Linux which interpreter runs this file.
  - `#!/bin/bash` — fixed path
  - `#!/usr/bin/env bash` — finds bash on the PATH (more portable, e.g. macOS + brew)
  - `#!/bin/sh` — POSIX shell (may be `dash`, NOT bash!)
- `#` starts a comment.

## 📖 Lesson 2.2 — Three ways to run it

```bash
bash hello.sh          # 1. pass to bash (no execute permission needed)
chmod +x hello.sh
./hello.sh             # 2. execute directly (uses the shebang)
source hello.sh        # 3. run in the CURRENT shell (or: . hello.sh)
```

> `./` is needed because the current directory is **not** on the `PATH` (for security).
> `source` is used for scripts that set variables/functions you want to keep (like `~/.bashrc`).

## 📖 Lesson 2.3 — `echo` vs `printf`

```bash
echo "Simple line"
echo -n "no newline"           # -n = no trailing newline
echo -e "Tab:\tNewline:\nDone" # -e = interpret escapes (bash)

printf "%s has %d CPUs\n" "web-01" 4        # format string, like C/Python
printf "%-10s %5s\n" "HOST" "CPU"            # aligned columns
printf "%-10s %5.1f\n" "web-01" 45.27
```

> 💡 Prefer `printf` for anything formatted or portable — `echo` behaves differently across shells.

## 📖 Lesson 2.4 — Command substitution

Capture a command's output into a variable or a string:

```bash
host=$(hostname)
kernel=$(uname -r)
files=$(ls | wc -l)
echo "Running on ${host} (kernel ${kernel}), ${files} files here"
```

Old syntax with backticks `` `hostname` `` works but `$(...)` is preferred (nestable, readable).

## 📖 Lesson 2.5 — Exit codes

Every command returns an exit code: **0 = success**, **1–255 = failure**.

```bash
ls /etc > /dev/null
echo $?               # 0
ls /nope 2> /dev/null
echo $?               # 2 (non-zero = failed)
```

Use them to chain commands:

```bash
mkdir -p build && cd build && echo "ready"               # && = run next only if previous succeeded
ping -c1 -W1 10.0.0.99 > /dev/null || echo "host down"   # || = run next only if previous failed
sudo apt update; sudo apt upgrade -y                     # ;  = run next regardless
```

End your own script with an exit code:
```bash
exit 0      # success
exit 1      # failure
```

## 📖 Lesson 2.6 — Here documents (multi-line text)

```bash
cat <<EOF
=========================
 Server: $(hostname)
 User:   $USER
=========================
EOF

cat > /tmp/app.conf <<'EOF'
# quoted 'EOF' → NO variable expansion: $HOME stays literal
log_dir=$HOME/logs
EOF
```

> ⚠️ The closing `EOF` must be alone on its line with no spaces before it.

## 📖 Lesson 2.7 — Put your scripts on the PATH

```bash
echo "$PATH"                     # dirs searched for commands
mkdir -p ~/bin
cp hello.sh ~/bin/hello
chmod +x ~/bin/hello
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
hello                            # now works from anywhere!
```

## 📖 Lesson 2.8 — Script template (use this every time)

```bash
#!/usr/bin/env bash
#
# name.sh — one-line description of what it does
# Usage: ./name.sh [args]
#
set -euo pipefail    # stop on errors — explained in Module 09

main() {
    echo "do work here"
}

main "$@"
```

## ⚠️ Common mistakes
- Windows line endings (`\r\n`) → `bad interpreter: /bin/bash^M`. Fix: `dos2unix file.sh` or `sed -i 's/\r$//' file.sh`
- Forgetting `chmod +x` → `Permission denied`
- Running with `sh script.sh` when the script uses Bash features → weird errors
- Shebang not on the very first line

---

## 🧪 Labs

### Lab 1 ⭐ — Hello server
Write `hello_server.sh` that prints a banner with hostname, current user, date, and uptime
using command substitution and a heredoc.

### Lab 2 ⭐ — System report script
Turn Module 01 Lab 4 into `sysreport.sh`: OS, kernel, uptime, disk `/`, memory, IP — neatly
aligned with `printf "%-12s %s\n"`.

### Lab 3 ⭐⭐ — Exit code explorer
Write `exitcodes.sh` that runs `true`, `false`, `ls /`, `ls /nope`, `grep root /etc/passwd`,
`grep nobody-xyz /etc/passwd` and prints each command with its exit code.

### Lab 4 ⭐⭐ — Install it
Copy your `sysreport.sh` into `~/bin/sysreport`, add `~/bin` to your PATH, and run `sysreport` from `/tmp`.

---

## ✅ Checkpoint
- [ ] I know what the shebang does and when to use `bash` vs `sh`
- [ ] I can use `$(...)`, `$?`, `&&`, `||`
- [ ] I start new scripts from the template

👉 Next: [Module 03 — Variables, Input & Arguments](../03-variables-input-args/README.md)
