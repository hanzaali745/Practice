# Bash Module 04 — Strict Mode, Error Handling & Debugging 🔴

> 🔁 **Builds on [Shell Module 08](../../2-shell-scripting/08-exit-codes-and-errors/README.md).**
> New in Bash: **`pipefail`** (fails on errors anywhere in a pipeline), **`trap ... ERR`** with
> `$LINENO`, the `set -e` gotchas specific to Bash, and **`PS4`** for better tracing.

## 🎯 Objectives
- Use **strict mode**: `set -euo pipefail` — and know its traps
- Check and propagate exit codes properly
- Clean up with `trap` (temp files, locks) on exit, error and Ctrl+C
- Debug with `bash -x`, `set -x`, `PS4`, and ShellCheck
- Prevent two copies of a script running at once (`flock`)

## 🧠 Why DevOps engineers care
By default, Bash **keeps going after errors**. A failed `cd` followed by `rm -rf *` has
deleted entire servers in real incidents. Strict mode, traps and good exit codes are what
separate a hobby script from something you trust in production at 3 a.m.

---

## 📖 Lesson 4.1 — The danger of default Bash

```bash
#!/usr/bin/env bash
cd /opt/myapp/releases/old     # fails — directory doesn't exist...
rm -rf ./*                     # ...so this runs in WHATEVER directory you're in 😱
echo "cleanup done"            # and it reports success
```

## 📖 Lesson 4.2 — Strict mode

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Option | Effect |
|--------|--------|
| `-e` (errexit) | exit immediately when a command fails |
| `-u` (nounset) | error on using an **unset** variable (catches typos!) |
| `-o pipefail` | a pipeline fails if **any** command in it fails (not just the last) |

```bash
set -o pipefail
grep "x" /nope | sort      # without pipefail: exit 0 (sort succeeded). With it: exit 2 ✅
```

**When you *expect* a command may fail**, handle it explicitly:
```bash
if ! grep -q "ERROR" app.log; then echo "no errors"; fi   # in an if → doesn't trigger -e
count=$(grep -c "ERROR" app.log || true)                   # allow failure
rm -f maybe-missing.txt                                    # -f = ok if missing
optional="${OPTIONAL_VAR:-}"                               # safe with -u
```

**Gotchas of `set -e`** (know them!):
```bash
count=0
(( count++ ))     # ❌ returns status 1 when the old value was 0 → script EXITS
(( ++count ))     # ✅ pre-increment returns the new value (1) → OK
count=$(( count + 1 ))   # ✅ always safe

local out=$(failing_cmd)   # ❌ `local` hides the failure
local out; out=$(failing_cmd)   # ✅ declare first, then assign
```

## 📖 Lesson 4.3 — Exit codes in your own scripts

| Code | Convention |
|------|-----------|
| `0` | success |
| `1` | general error |
| `2` | misuse / bad arguments |
| `126` | command not executable |
| `127` | command not found |
| `128+N` | killed by signal N (130 = Ctrl+C, 137 = kill -9 / OOM) |

```bash
die() { echo "ERROR: $*" >&2; exit 1; }

[[ $# -ge 1 ]] || { echo "Usage: $0 <file>" >&2; exit 2; }
[[ -f $1 ]]    || die "file not found: $1"
cp "$1" /backup/ || die "copy failed"
```

Capture an exit code without triggering `set -e`:
```bash
status=0
some_command || status=$?
if (( status != 0 )); then echo "failed with $status"; fi
```

## 📖 Lesson 4.4 — `trap`: cleanup no matter what

```bash
#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)                         # safe temp directory
cleanup() {
    rm -rf "$tmpdir"
    echo "cleaned up $tmpdir" >&2
}
trap cleanup EXIT                           # runs on ANY exit: success, error, Ctrl+C

echo "working in $tmpdir"
cp /etc/hosts "$tmpdir/"
false                                       # error → script exits → cleanup still runs ✅
```

Useful signals:

| Trap | When |
|------|------|
| `EXIT` | script ends for any reason |
| `ERR` | a command fails (with `set -e`) |
| `INT` | Ctrl+C |
| `TERM` | `kill PID`, `docker stop`, systemd stop |

Report **where** an error happened:
```bash
trap 'echo "ERROR on line $LINENO: $BASH_COMMAND (exit $?)" >&2' ERR
```

## 📖 Lesson 4.5 — Debugging

```bash
bash -n script.sh          # syntax check only (doesn't run)
bash -x script.sh          # trace: print every command before running it
```

Trace only a section:
```bash
set -x
risky_part
set +x
```

Better trace output with file/line/function:
```bash
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main}: '
bash -x script.sh
```

**ShellCheck** catches most bugs before you run anything:
```bash
shellcheck script.sh
```
Treat its warnings like compiler errors. If you *really* must ignore one:
```bash
# shellcheck disable=SC2086
```

## 📖 Lesson 4.6 — Locking: only one instance at a time

Cron jobs can overlap if a run takes longer than its interval. Prevent it:

```bash
exec 9> /tmp/backup.lock
if ! flock -n 9; then
    echo "Another backup is already running" >&2
    exit 1
fi
# ... rest of script; lock is released automatically on exit
```

## 📖 Lesson 4.7 — Retry helper (production pattern)

```bash
retry() {
    local attempts="$1" delay="$2"; shift 2
    local n=1
    until "$@"; do
        if (( n >= attempts )); then
            echo "failed after $n attempts: $*" >&2
            return 1
        fi
        echo "attempt $n failed, retrying in ${delay}s..." >&2
        sleep "$delay"
        (( ++n ))
        delay=$(( delay * 2 ))     # exponential backoff
    done
}

retry 5 2 curl -sf https://example.com/health
```

---

## ⚠️ Common mistakes
- No `set -euo pipefail` at the top
- `(( i++ ))` with `set -e` when `i` is 0
- `local var=$(cmd)` hiding failures
- Temp files left behind (no `trap ... EXIT`)
- Error messages on stdout instead of stderr; exit 0 after a failure

---

## 🧪 Labs

### Lab 1 ⭐ — Break it & fix it
Run `solutions/lab1_unsafe.sh` and see it keep going after errors. Add strict mode and
watch it stop. Then fix each problem properly (see `lab1_safe.sh`).

### Lab 2 ⭐⭐ — Trap & cleanup
Write a script that creates a temp dir, downloads/copies files into it, and *always* removes
it — on success, on error (`false`), and on Ctrl+C (try it during a `sleep 30`).
Print the line number of any failure using an `ERR` trap.

### Lab 3 ⭐⭐ — Retry with backoff
Implement `retry <attempts> <delay> <command...>`. Test it with a command that fails twice then
succeeds (hint: use a counter file in `/tmp`).

### Lab 4 ⭐⭐⭐ — Safe job runner
Write `safe_job.sh` that combines: strict mode, `flock` single-instance lock, `trap` cleanup,
`ERR` trap with line numbers, logging to a file with timestamps, and an exit code summary.
Run two copies at the same time to prove the lock works.

---

## ✅ Checkpoint
- [ ] Every script I write starts with `set -euo pipefail`
- [ ] I clean up temp files with `trap ... EXIT`
- [ ] I can debug with `bash -x` and I run ShellCheck on everything

👉 Next: [Module 05 — Remote Servers: SSH, scp & rsync](../05-remote-servers-ssh/README.md)
