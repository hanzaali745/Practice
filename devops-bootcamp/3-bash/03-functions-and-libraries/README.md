# Bash Module 03 — Functions & Libraries 🟡

> 🔁 **Builds on [Shell Module 06](../../2-shell-scripting/06-functions/README.md).** Lessons 3.1–3.2 are a
> quick recap. The new Bash-only parts are **`local`** (3.3), **coloured logging** (3.5),
> **`BASH_SOURCE`** for libraries (3.6) and **`${var^^}`/`${var,,}`** in the labs.

## 🎯 Objectives
- Recap: define and call functions with arguments
- Use **`local`** variables (Bash) instead of the POSIX workarounds
- "Return" data via stdout and status via `return`
- Build a reusable **library** file and `source` it
- Write logging helpers you'll use in every script

## 🧠 Why DevOps engineers care
Without functions, scripts become 500-line walls of copy-paste. With them, you get
readable scripts like `check_disk; backup_db; notify_slack` — and a shared library your
whole team can `source`.

---

## 📖 Lesson 3.1 — Defining & calling

```bash
greet() {
    echo "Hello from a function"
}

greet            # call it — no parentheses!
```

Functions must be **defined before** they're called (that's why we put `main "$@"` at the bottom).

## 📖 Lesson 3.2 — Arguments

Inside a function, `$1`, `$2`, `$#`, `$@` refer to the **function's** arguments.

```bash
deploy() {
    local app="$1"
    local env="${2:-dev}"
    echo "Deploying $app to $env"
}

deploy api prod
deploy web
```

## 📖 Lesson 3.3 — `local` variables

Without `local`, variables are **global** and leak out of the function:

```bash
counter() {
    local count=5      # ✅ only inside the function
    total=10           # ❌ global — visible everywhere after the call
}
counter
echo "${count:-unset} $total"   # unset 10
```

> 🧠 Rule: **every variable inside a function is `local`** unless you deliberately need a global.

## 📖 Lesson 3.4 — Returning values

Bash functions have two outputs:
1. **Exit status** with `return N` (0–255) → for success/failure
2. **Data** via `echo` → captured with `$(...)`

```bash
is_port_valid() {
    local port="$1"
    [[ $port =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 ))
    # the status of the last command is returned automatically
}

if is_port_valid 8080; then echo "valid"; fi

get_disk_usage() {
    local mount="${1:-/}"
    df --output=pcent "$mount" | tail -1 | tr -dc '0-9'
}

usage=$(get_disk_usage /)
echo "Root disk at ${usage}%"
```

> ⚠️ `return "hello"` doesn't work — `return` is only for numbers. Echo data instead.

## 📖 Lesson 3.5 — Logging helpers (copy these into every script!)

```bash
readonly RED=$'\e[31m' GREEN=$'\e[32m' YELLOW=$'\e[33m' RESET=$'\e[0m'

log()   { printf '%s [INFO]  %s\n' "$(date '+%F %T')" "$*"; }
ok()    { printf '%s [ OK ]  %s%s%s\n' "$(date '+%F %T')" "$GREEN" "$*" "$RESET"; }
warn()  { printf '%s [WARN]  %s%s%s\n' "$(date '+%F %T')" "$YELLOW" "$*" "$RESET" >&2; }
error() { printf '%s [ERROR] %s%s%s\n' "$(date '+%F %T')" "$RED" "$*" "$RESET" >&2; }
die()   { error "$*"; exit 1; }

log "Starting backup"
warn "Disk at 85%"
[[ -d /data ]] || die "/data does not exist"
```

## 📖 Lesson 3.6 — Function libraries with `source`

`lib/common.sh`:
```bash
# shellcheck shell=bash
log() { printf '[%s] %s\n' "$(date +%T)" "$*"; }
require_cmd() { command -v "$1" &>/dev/null || { echo "missing: $1" >&2; exit 1; }; }
```

`deploy.sh`:
```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"     # works no matter where you run it from

require_cmd docker
log "All good"
```

`SCRIPT_DIR` trick = the folder the script lives in. Essential for scripts that use relative files.

## 📖 Lesson 3.7 — The `main` pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: $0 <app> <env>" >&2; exit 1; }

check()  { echo "checking $1"; }
build()  { echo "building $1"; }
deploy() { echo "deploying $1 to $2"; }

main() {
    [[ $# -eq 2 ]] || usage
    local app="$1" env="$2"
    check "$app"
    build "$app"
    deploy "$app" "$env"
}

main "$@"
```

Reads like a table of contents. Everyone on the team can understand it in 10 seconds.

---

## ⚠️ Common mistakes
- Calling a function before it's defined
- Forgetting `local` → mysterious global variable bugs
- Using `return` for strings
- `echo`ing log messages to stdout inside a function whose output you capture → logs get
  mixed into your data. Send logs to **stderr** (`>&2`).

---

## 🧪 Labs

### Lab 1 ⭐ — Utility functions
Write `to_upper`, `to_lower`, `trim` (remove leading/trailing whitespace) and `repeat <char> <n>`.
Test each.

### Lab 2 ⭐⭐ — Validators
Write `is_number`, `is_valid_port`, `is_valid_ip` (4 octets 0–255) that only use exit status.
Test them in a loop with valid and invalid inputs, printing ✅/❌.

### Lab 3 ⭐⭐ — Logging library
Create `lib/logging.sh` with `log`, `ok`, `warn`, `error`, `die`, plus `LOG_FILE` support
(if set, also append each message to it, without colours). Write `demo.sh` that sources it
using the `SCRIPT_DIR` trick.

### Lab 4 ⭐⭐⭐ — Health check script with functions
Write `health.sh` with functions `check_disk`, `check_memory`, `check_load`, `check_service <name>`,
each returning 0/1 and logging via your library. `main` runs all, counts failures, and exits
non-zero if any failed.

---

## ✅ Checkpoint
- [ ] All my function variables are `local`
- [ ] I return data with `echo` + `$(...)`, status with `return`
- [ ] I can `source` a library relative to the script's own directory

👉 Next: [Module 04 — Strict Mode & Debugging](../04-strict-mode-and-debugging/README.md)
