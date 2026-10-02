# Shell Module 08 — Exit Codes & Errors 🟡

## 🎯 Objectives
- Understand why shell scripts are dangerous by default
- Use `set -eu` and know exactly what it does (and doesn't) protect
- Use exit codes correctly, and write a `die` helper
- Clean up temp files with `trap ... EXIT` — even on `Ctrl+C`
- Debug with `sh -n`, `sh -x` and ShellCheck
- Stop two copies of a script running at once with `flock`

## 🧠 Why DevOps engineers care
By default the shell **keeps going after a command fails**. A failed `cd` followed by
`rm -rf *` has wiped real production servers. Safe defaults, cleanup and correct exit codes are
what make a script trustworthy at 3 a.m. — and what tells cron, CI and monitoring that something broke.

---

## 📖 Lesson 8.1 — The danger of default shell behaviour

```sh
#!/bin/sh
cd /opt/myapp/releases/old     # fails: directory doesn't exist...
rm -rf ./*                     # ...so this runs in WHATEVER folder you were in 😱
echo "cleanup done"            # and the script reports success
```

Run [`solutions/lab1_unsafe.sh`](solutions/lab1_unsafe.sh) (it's harmless) and watch it carry on after every error.

## 📖 Lesson 8.2 — `set -eu`

```sh
#!/bin/sh
set -eu
```

| Option | What it does |
|--------|--------------|
| `-e` | **exit** as soon as a command fails |
| `-u` | treat using an **unset** variable as an error (catches typos like `$APP_NMAE`) |

When you **expect** a command might fail, say so explicitly — then `-e` won't stop the script:

```sh
if ! grep -q "ERROR" app.log; then         # commands tested by if / while / ! never trigger -e
    echo "no errors"
fi
count=$(grep -c "ERROR" app.log || true)   # "|| true" = failure is OK here
rm -f maybe-missing.txt                    # -f = don't fail if the file is missing
optional="${OPTIONAL_VAR:-}"               # safe with -u: empty default
```

### What `set -e` does NOT catch (know these!)

```sh
false | true        # a pipeline's status is the LAST command → this "succeeds"
```
POSIX `sh` on Ubuntu (dash) has **no** `set -o pipefail`. If a failure early in a pipeline
matters, check it separately or save the output to a file first.
Bash has `pipefail` — you'll use it in Phase 3.

## 📖 Lesson 8.3 — Exit codes

| Code | Meaning (convention) |
|------|----------------------|
| `0` | success |
| `1` | general error |
| `2` | wrong usage / bad arguments |
| `126` | found but not executable |
| `127` | command not found |
| `128+N` | killed by signal N → `130` = Ctrl+C, `137` = `kill -9` or out of memory, `143` = `kill` (TERM) |

Your scripts should follow them:

```sh
die() { echo "ERROR: $*" >&2; exit 1; }

[ $# -ge 1 ] || { echo "Usage: $0 <file>" >&2; exit 2; }
[ -f "$1" ]  || die "file not found: $1"
cp "$1" /backup/ || die "copy failed"
```

Keep a failing command's exit code without triggering `set -e`:
```sh
status=0
some_command || status=$?
if [ "$status" -ne 0 ]; then
    echo "some_command failed with $status"
fi
```

## 📖 Lesson 8.4 — `trap`: clean up no matter what

`trap 'commands' SIGNALS` runs your commands when the script receives that signal or exits.

```sh
#!/bin/sh
set -eu

tmpdir=$(mktemp -d)                       # safe, unique temp folder (never invent temp names)
trap 'rm -rf "$tmpdir"' EXIT              # runs when the script ends — success OR failure
trap 'exit 130' INT                       # Ctrl+C → exit (which then runs the EXIT trap)
trap 'exit 143' TERM                      # kill / docker stop → same

echo "working in $tmpdir"
cp /etc/hosts "$tmpdir/"
false                                     # fails → script exits → EXIT trap still cleans up ✅
```

| Signal name | When |
|-------------|------|
| `EXIT` | the script ends for any reason |
| `INT` | `Ctrl+C` |
| `TERM` | `kill PID`, `docker stop`, `systemctl stop` |
| `HUP` | terminal closed (often used for "reload config") |

> `trap ... ERR` (run something on every error) is **Bash only** — Phase 3.

## 📖 Lesson 8.5 — Debugging

```sh
sh -n script.sh       # syntax check only — doesn't run anything
sh -x script.sh       # trace: prints every command (with values) before running it
```

Trace just one part of a script:
```sh
set -x        # start tracing
risky_part
set +x        # stop tracing
```

And always:
```sh
shellcheck -s sh script.sh
```
Treat every ShellCheck warning like a bug. Each has a code like `SC2086` — search it to learn why.

## 📖 Lesson 8.6 — Only one copy at a time (`flock`)

If a cron job runs every 5 minutes but sometimes takes 7, two copies overlap and corrupt things.
`flock` (installed on Ubuntu) prevents it:

```sh
exec 9> /tmp/myjob.lock          # open file descriptor 9 on a lock file
if ! flock -n 9; then            # -n = don't wait; fail if someone else holds the lock
    echo "Already running, exiting" >&2
    exit 1
fi
# ... the rest of the job. The lock is released automatically when the script exits.
```

Or wrap any command without changing it:
```sh
flock -n /tmp/backup.lock sh /opt/scripts/backup.sh
```

## 📖 Lesson 8.7 — A retry helper

```sh
retry() {
    retry_max="$1"; retry_delay="$2"; shift 2
    retry_n=1
    until "$@"; do
        if [ "$retry_n" -ge "$retry_max" ]; then
            echo "failed after $retry_n attempts: $*" >&2
            return 1
        fi
        echo "attempt $retry_n failed, retrying in ${retry_delay}s..." >&2
        sleep "$retry_delay"
        retry_n=$((retry_n + 1))
        retry_delay=$((retry_delay * 2))       # exponential backoff: 2, 4, 8...
    done
}

retry 5 2 curl -sf https://example.com/health
```

---

## 🛡️ The safe script template (use from now on)

```sh
#!/bin/sh
#
# name.sh — what it does
# Usage: sh name.sh ARGS
#
set -eu

die() { echo "ERROR: $*" >&2; exit 1; }

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

main() {
    [ $# -ge 1 ] || { echo "Usage: $0 ARGS" >&2; exit 2; }
    # work goes here
}

main "$@"
```

---

## ⚠️ Common mistakes
- No `set -eu`
- Thinking `set -e` catches failures inside pipelines (it doesn't in sh)
- Temp files left behind — no `trap ... EXIT`
- Error messages on stdout, and `exit 0` after a failure
- Hand-made temp names like `/tmp/myfile` instead of `mktemp`

---

## 🧪 Labs
Work in `my-work/shell/`.

### Lab 1 ⭐ — Break it, then fix it
Run `solutions/lab1_unsafe.sh` and write down every problem you see. Then write your own safe
version with `set -eu`, explicit checks and defaults. Compare with `lab1_safe.sh`.

### Lab 2 ⭐⭐ — Always clean up
Write a script that makes a temp dir with `mktemp -d`, copies some files in, and **always**
deletes it — on success, on failure (`sh lab2_trap.sh fail`), and on `Ctrl+C`
(`sh lab2_trap.sh slow`, then press `Ctrl+C`). Print the exit status in the cleanup.

### Lab 3 ⭐⭐ — Retry with backoff
Implement `retry <attempts> <delay> <command...>`. Test it with a function that fails twice and
then succeeds (keep a counter in a temp file).

### Lab 4 ⭐⭐⭐ — Safe job runner
Combine everything: `set -eu`, a `flock` lock, `trap` cleanup, timestamped logging to a file, and a
"finished OK / FAILED with code N" message on exit. Start it twice at the same time to prove the lock works:
`sh lab4_safe_job.sh 3 & sh lab4_safe_job.sh 1`

---

## ✅ Checkpoint
- [ ] Every script I write starts with `set -eu`
- [ ] I know `set -e` does not cover pipelines in sh
- [ ] I clean up with `trap ... EXIT` and use `mktemp`
- [ ] I use exit code 2 for bad usage and 1 for failures
- [ ] I can debug with `sh -x` and fix ShellCheck warnings

👉 Next: [Module 09 — Processes & Scheduling](../09-processes-and-scheduling/README.md)
