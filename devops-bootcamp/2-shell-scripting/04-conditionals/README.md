# Shell Module 04 — Conditionals 🟢

## 🎯 Objectives
- Write `if / elif / else`
- Use `[ ]` (the `test` command) for strings, numbers and files
- Combine conditions with `&&`, `||`, `!`
- Use `case` for menus, commands and pattern matching
- Branch directly on whether a command succeeded (`if grep -q ...`)

## 🧠 Why DevOps engineers care
"Is the service running?" "Does the config exist?" "Is the disk above 90%?" "Are we on prod?"
A safe script **checks before it acts**.

---

## 📖 Lesson 4.1 — `if` syntax

```sh
if [ condition ]; then
    echo "yes"
elif [ other_condition ]; then
    echo "second choice"
else
    echo "fallback"
fi
```

> ⚠️ **Spaces are required** inside the brackets: `[ "$a" = "$b" ]` ✅ — `["$a"="$b"]` ❌
> `[` is actually a **command** (try `which [`), so it needs spaces like any command.

## 📖 Lesson 4.2 — String tests

| Test | True when |
|------|-----------|
| `[ "$a" = "$b" ]` | equal (**one** `=` in POSIX!) |
| `[ "$a" != "$b" ]` | not equal |
| `[ -z "$a" ]` | empty |
| `[ -n "$a" ]` | not empty |

```sh
env="${1:-}"
if [ -z "$env" ]; then
    echo "Usage: $0 <env>" >&2
    exit 2
elif [ "$env" = "prod" ]; then
    echo "⚠️  Production! Be careful."
fi
```

> ⚠️ `[ "$a" == "$b" ]` works in Bash but **fails in dash**: `[: unexpected operator`.
> In `sh` scripts always use a single `=`.
> 🧠 **Always quote variables inside `[ ]`.** `[ $a = prod ]` crashes when `$a` is empty.

## 📖 Lesson 4.3 — Number tests

| Test | Meaning |
|------|---------|
| `-eq` | equal |
| `-ne` | not equal |
| `-gt` / `-ge` | greater than / greater or equal |
| `-lt` / `-le` | less than / less or equal |

```sh
usage=87
if [ "$usage" -ge 90 ]; then
    echo "CRITICAL"
elif [ "$usage" -ge 75 ]; then
    echo "WARNING"
else
    echo "OK"
fi
```

> ⚠️ `[ 10 > 9 ]` does **not** compare numbers — `>` creates a file called `9`! Use `-gt`.

## 📖 Lesson 4.4 — File tests

| Test | True when |
|------|-----------|
| `-e path` | exists (anything) |
| `-f path` | is a regular file |
| `-d path` | is a directory |
| `-r` / `-w` / `-x` | readable / writable / executable |
| `-s path` | exists and is not empty |
| `-L path` | is a symbolic link |

```sh
config="/etc/nginx/nginx.conf"
if [ ! -f "$config" ]; then
    echo "Config missing: $config" >&2
    exit 1
fi
[ -d /var/backups ] || mkdir -p /var/backups      # short form: "if not a dir, create it"
[ -x /usr/bin/docker ] && echo "docker is installed"
```

## 📖 Lesson 4.5 — Combining conditions

```sh
if [ "$env" = "prod" ] && [ "$replicas" -lt 2 ]; then
    echo "prod needs at least 2 replicas"
fi
if [ "$user" = "root" ] || [ "$user" = "admin" ]; then
    echo "privileged user"
fi
if [ ! -d /data ]; then
    echo "no /data directory"
fi
```

Use **separate `[ ]` joined by `&&` / `||`**. (You may see `-a` / `-o` inside one `[ ]` — avoid them, they're deprecated and buggy.)

## 📖 Lesson 4.6 — Commands as conditions

`if` really checks the **exit code** of a command. `[` is just one such command!

```sh
if grep -q "ERROR" app.log; then                 # -q = quiet, only the exit code matters
    echo "Errors found"
fi

if ping -c1 -W2 8.8.8.8 > /dev/null 2>&1; then
    echo "online"
else
    echo "offline"
fi

if ! command -v docker > /dev/null 2>&1; then    # is a tool installed?
    echo "docker is required" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then                    # running as root?
    echo "Please run with sudo" >&2
    exit 1
fi
```

## 📖 Lesson 4.7 — `case` (your best friend in sh)

```sh
case "$1" in
    start)
        echo "Starting..."
        ;;
    stop)
        echo "Stopping..."
        ;;
    restart|reload)                 # | = OR
        echo "Restarting..."
        ;;
    *.tar.gz|*.tgz)                 # wildcard patterns work!
        echo "That's a tarball"
        ;;
    "")
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 2
        ;;
    *)                              # * = anything else
        echo "Unknown command: $1" >&2
        exit 2
        ;;
esac
```

`case` is also how you do **pattern matching** in POSIX sh:

```sh
host="web-07"
case "$host" in
    web-*) echo "web server" ;;
    db-*)  echo "database"   ;;
esac

case "$port" in
    ''|*[!0-9]*) echo "not a number" ;;     # empty, or contains a non-digit
    *)           echo "number" ;;
esac
```

## 📖 Lesson 4.8 — Confirmation prompt (production safety)

```sh
printf "Deploy to PRODUCTION? Type 'yes' to continue: "
read -r confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi
```

---

## ⚠️ Common mistakes
- No spaces inside `[ ]`
- `==` instead of `=` (fails in dash)
- Unquoted variables in tests
- `>` / `<` for numbers (use `-gt` / `-lt`)
- Forgetting `fi`, `esac`, or `;;`

---

## 🧪 Labs
Work in `my-work/shell/`. Run with `sh`. Lint with `shellcheck -s sh`.

### Lab 1 ⭐ — Disk check (Nagios style)
`disk_check.sh [mount] [warn] [crit]` (defaults `/`, `80`, `90`). Print `OK`, `WARNING` or `CRITICAL`.
Exit codes: `0` OK, `1` WARNING, `2` CRITICAL, `3` UNKNOWN (mount doesn't exist). This is the
**Nagios/Icinga** monitoring convention.

**Steps:** 1) set defaults with `${1:-/}` 2) check `[ -d "$mount" ]` 3) get the usage number:
`df -P "$mount" | awk 'NR==2 {sub("%","",$5); print $5}'` 4) compare with `-ge`.

### Lab 2 ⭐ — File inspector
`inspect.sh <path>`: does it exist? file / directory / symlink? readable / writable / executable?
empty? size (for files: `wc -c < "$path"`).

### Lab 3 ⭐⭐ — Tool checker
`require.sh` checks that `git`, `curl`, `python3`, `jq`, `docker` are installed with `command -v`,
prints ✅/❌ for each, and exits 1 if any are missing.

### Lab 4 ⭐⭐ — Environment guard
`guard.sh <env>` accepts only `dev`, `staging`, `prod` (use `case`). For `prod`, ask for `yes`.
Then check `config/<env>.yml` exists and print `Loading config/<env>.yml`.

### Lab 5 ⭐⭐⭐ — Service control
`svc.sh {start|stop|restart|status} <service>` using `case`. Fake the service with a file
`/tmp/<service>.pid` (start writes `$$` into it, stop deletes it, status checks it).
`restart` = stop then start. `status` exits 3 when stopped (like real init scripts).

---

## ✅ Checkpoint
- [ ] I put spaces inside `[ ]` and quote every variable
- [ ] I use `=` for strings and `-eq/-gt/-lt` for numbers
- [ ] I know `-f -d -e -x -s`
- [ ] I can use `case` for commands and wildcard patterns

👉 Next: [Module 05 — Loops](../05-loops/README.md)
