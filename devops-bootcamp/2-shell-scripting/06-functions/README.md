# Shell Module 06 — Functions 🟡

## 🎯 Objectives
- Define and call functions
- Pass arguments to functions (`$1`, `$@`)
- Return a **status** with `return` and **data** with `echo` + `$(...)`
- Keep variables from leaking between functions
- Build a reusable **library** file and load it with `.`
- Write logging helpers you'll reuse in every script

## 🧠 Why DevOps engineers care
Without functions, scripts become 500-line walls of copy-paste. With them, a script reads like
a checklist: `check_disk; backup_db; notify` — and your team shares one tested library.

---

## 📖 Lesson 6.1 — Define and call

```sh
greet() {
    echo "Hello from a function"
}

greet          # call it — just the name, NO parentheses
greet          # call it again as often as you like
```

A function must be **defined before** it is called. That's why scripts define functions first
and call `main "$@"` on the last line.

> In POSIX sh, write `name() { ...; }`. The `function name { }` style is Bash-only.

## 📖 Lesson 6.2 — Arguments

Inside a function, `$1`, `$2`, `$#`, `$@` are the **function's own** arguments
(not the script's):

```sh
deploy() {
    app="$1"
    env="${2:-dev}"
    echo "Deploying $app to $env"
}

deploy api prod     # Deploying api to prod
deploy web          # Deploying web to dev
```

## 📖 Lesson 6.3 — Returning things

A function has two ways to give something back:

**1. A status (success/failure)** with `return N` (0 = success, 1–255 = failure):
```sh
is_root() {
    [ "$(id -u)" -eq 0 ]        # a function returns the status of its LAST command
}

if is_root; then echo "running as root"; else echo "not root"; fi
```

**2. Data** by printing it, captured with `$(...)`:
```sh
disk_usage() {
    df -P "${1:-/}" | awk 'NR == 2 { sub("%", "", $5); print $5 }'
}

usage=$(disk_usage /)
echo "Root disk at ${usage}%"
```

> ⚠️ `return "hello"` doesn't work — `return` only takes a number. Print data instead.

## 📖 Lesson 6.4 — Variables leak out of functions (and how to stop it)

In POSIX sh, variables set inside a function are **global**:

```sh
set_name() {
    name="from-function"
}
name="original"
set_name
echo "$name"        # from-function   ← the function overwrote it!
```

Two clean ways to avoid surprises:

**a) Use unique, descriptive names** (e.g. `disk_mount` instead of `x`).

**b) Run the function body in a sub-shell** with `( )` instead of `{ }` — nothing can leak out:
```sh
safe_calc() (
    name="temporary"            # only exists inside this function
    echo "inside: $name"
)
name="original"
safe_calc
echo "$name"                    # original ✅
```

> You'll often see `local name=...` in scripts. `local` is **not** part of POSIX, but `dash`,
> `ash` and BusyBox support it, and Bash has it (Phase 3 uses it everywhere). `shellcheck -s sh`
> warns about it, so in this phase we use (a) and (b).

## 📖 Lesson 6.5 — Logging helpers (copy these into every script)

```sh
log()   { printf '%s [INFO]  %s\n' "$(date '+%F %T')" "$*" >&2; }
warn()  { printf '%s [WARN]  %s\n' "$(date '+%F %T')" "$*" >&2; }
error() { printf '%s [ERROR] %s\n' "$(date '+%F %T')" "$*" >&2; }
die()   { error "$*"; exit 1; }

log "Starting backup"
warn "Disk at 85%"
[ -d /data ] || die "/data does not exist"
```

They write to **stderr** (`>&2`) so log messages never mix with real output that someone
might capture with `$(...)` or pipe to another command.

## 📖 Lesson 6.6 — Function libraries

Put shared functions in their own file and **load** them with `.` (the POSIX "source" command).

`lib/logging.sh`:
```sh
# shellcheck shell=sh
log() { printf '%s [INFO] %s\n' "$(date '+%F %T')" "$*" >&2; }
die() { printf '%s [ERROR] %s\n' "$(date '+%F %T')" "$*" >&2; exit 1; }
```

`deploy.sh`:
```sh
#!/bin/sh
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)     # the folder this script lives in
. "$SCRIPT_DIR/lib/logging.sh"                # load the library

log "Library loaded"
```

`SCRIPT_DIR` makes the script work **no matter which folder you run it from**.

## 📖 Lesson 6.7 — The `main` pattern

```sh
#!/bin/sh
set -eu

usage() { echo "Usage: $0 <app> <env>" >&2; exit 2; }

check()  { echo "checking $1"; }
build()  { echo "building $1"; }
deploy() { echo "deploying $1 to $2"; }

main() {
    [ $# -eq 2 ] || usage
    check "$1"
    build "$1"
    deploy "$1" "$2"
}

main "$@"
```

`main` reads like a table of contents — anyone can understand the script in 10 seconds.

---

## ⚠️ Common mistakes
- Calling a function before it's defined
- `function name {}` or `name() {}` with Bash features inside an `sh` script
- Using `return` for text
- Logging to stdout inside a function whose output you capture with `$(...)`
- Accidentally overwriting a global variable inside a function

---

## 🧪 Labs
Work in `my-work/shell/`.

### Lab 1 ⭐ — String helpers
Write `to_upper`, `to_lower` (use `tr`), `trim` (use `sed`) and `repeat <char> <n>`. Test each.

### Lab 2 ⭐⭐ — Validators
Write `is_number`, `is_valid_port`, `is_valid_ip` that **only** return a status (no output).
Hint: `is_number` with `case "$1" in ''|*[!0-9]*) return 1 ;; esac`.
For the IP, split on dots with `IFS=.` and `set -- $ip` inside a `( )` function.
Test them in a loop and print ✅/❌.

### Lab 3 ⭐⭐ — Logging library
Create `lib/logging.sh` with `log`, `ok`, `warn`, `error`, `die`. If the `LOG_FILE` variable is set,
also append each message to that file. Write `demo.sh` that loads it using `SCRIPT_DIR`.

### Lab 4 ⭐⭐⭐ — Health check from functions
`health.sh [process...]` with functions `check_disk`, `check_memory`, `check_load`,
`check_process <name>`. Each returns 0/1 and logs with your library. `main` counts failures and
exits 1 if any check failed.

---

## ✅ Checkpoint
- [ ] I define functions before calling them and finish with `main "$@"`
- [ ] I return status with `return`, data with `echo` + `$(...)`
- [ ] I know variables are global in sh, and how to keep them contained
- [ ] I can load a library relative to the script with `SCRIPT_DIR`

👉 Next: [Module 07 — Pipes & Text Processing](../07-pipes-and-text-processing/README.md)
