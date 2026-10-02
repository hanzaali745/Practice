# Module 04 — Conditionals 🟢

## 🎯 Objectives
- Write `if / elif / else` blocks
- Use `[[ ]]` tests for strings, numbers and files
- Combine conditions with `&&`, `||`, `!`
- Use `case` for menus and command dispatch
- Branch on a command's success directly (`if grep -q ...`)

## 🧠 Why DevOps engineers care
"Is the service running?" "Does the config file exist?" "Is disk above 90%?"
"Are we on prod?" Every safe script checks before it acts.

---

## 📖 Lesson 4.1 — `if` syntax

```bash
if [[ condition ]]; then
    echo "true branch"
elif [[ other_condition ]]; then
    echo "second branch"
else
    echo "fallback"
fi
```

> ⚠️ Spaces matter: `[[ $a == $b ]]` ✅ — `[[$a==$b]]` ❌

`[[ ]]` is Bash's modern test. `[ ]` (aka `test`) is the old POSIX version — you'll see it in
`sh` scripts (Module 12). Prefer `[[ ]]` in Bash: it's safer and supports `&&`, `||`, `=~`, patterns.

## 📖 Lesson 4.2 — String tests

| Test | True if |
|------|---------|
| `[[ $a == "$b" ]]` | equal |
| `[[ $a != "$b" ]]` | not equal |
| `[[ -z $a ]]` | empty (zero length) |
| `[[ -n $a ]]` | not empty |
| `[[ $a == web-* ]]` | glob pattern match (unquoted right side!) |
| `[[ $a =~ ^[0-9]+$ ]]` | regex match |

```bash
env="${1:-}"
if [[ -z $env ]]; then
    echo "Usage: $0 <env>" >&2; exit 1
elif [[ $env == "prod" ]]; then
    echo "⚠️  Production! Be careful."
fi

host="web-07"
[[ $host == web-* ]] && echo "web server"
[[ $host =~ ^web-([0-9]+)$ ]] && echo "number: ${BASH_REMATCH[1]}"   # 07
```

## 📖 Lesson 4.3 — Number tests

| Test | Meaning |
|------|---------|
| `-eq` | equal |
| `-ne` | not equal |
| `-gt` / `-ge` | greater / greater-or-equal |
| `-lt` / `-le` | less / less-or-equal |

```bash
usage=87
if [[ $usage -ge 90 ]]; then echo CRITICAL
elif [[ $usage -ge 75 ]]; then echo WARNING
else echo OK
fi

# Arithmetic context — reads more naturally
if (( usage >= 90 )); then echo "CRITICAL"; fi
```

> ⚠️ `[[ 10 > 9 ]]` compares as **strings** (false!). Use `-gt` or `(( ))` for numbers.

## 📖 Lesson 4.4 — File tests

| Test | True if |
|------|---------|
| `-e path` | exists |
| `-f path` | is a regular file |
| `-d path` | is a directory |
| `-r` / `-w` / `-x` | readable / writable / executable |
| `-s path` | exists and not empty |
| `-L path` | is a symlink |
| `a -nt b` | a is newer than b |

```bash
config="/etc/nginx/nginx.conf"
if [[ ! -f $config ]]; then
    echo "Config missing: $config" >&2
    exit 1
fi
[[ -d /var/backups ]] || mkdir -p /var/backups
[[ -x /usr/bin/docker ]] && echo "docker installed"
```

## 📖 Lesson 4.5 — Combining conditions

```bash
if [[ $env == "prod" && $replicas -lt 2 ]]; then
    echo "prod needs at least 2 replicas"
fi
if [[ $user == "root" || $user == "admin" ]]; then echo "privileged"; fi
if [[ ! -d /data ]]; then echo "no data dir"; fi
```

## 📖 Lesson 4.6 — Using commands as conditions

`if` actually checks the **exit code** of any command. `[[ ]]` is just one command!

```bash
if grep -q "ERROR" app.log; then           # -q = quiet, only exit code
    echo "Errors found"
fi

if ping -c1 -W2 8.8.8.8 &>/dev/null; then echo "online"; else echo "offline"; fi

if ! command -v docker &>/dev/null; then   # check a tool is installed
    echo "docker is required" >&2; exit 1
fi

if systemctl is-active --quiet nginx; then echo "nginx running"; fi

if [[ $EUID -ne 0 ]]; then                 # must run as root?
    echo "Run as root (sudo)" >&2; exit 1
fi
```

## 📖 Lesson 4.7 — `case` statements

Perfect for commands like `start|stop|restart`:

```bash
case "$1" in
    start)
        echo "Starting..." ;;
    stop)
        echo "Stopping..." ;;
    restart|reload)
        echo "Restarting..." ;;
    status)
        echo "Running" ;;
    *.tar.gz|*.tgz)
        echo "a tarball" ;;
    "")
        echo "Usage: $0 {start|stop|restart|status}" >&2; exit 1 ;;
    *)
        echo "Unknown command: $1" >&2; exit 1 ;;
esac
```

## 📖 Lesson 4.8 — Confirmation prompt (production safety)

```bash
read -r -p "Deploy to PRODUCTION? Type 'yes' to continue: " confirm
if [[ $confirm != "yes" ]]; then
    echo "Aborted."; exit 1
fi
```

---

## ⚠️ Common mistakes
- Missing spaces inside `[[ ` and ` ]]`
- Using `>` / `<` for numbers inside `[[ ]]` (string comparison!)
- Using `=` for numbers or `-eq` for strings
- Forgetting `fi` / `esac` / `;;`

---

## 🧪 Labs

### Lab 1 ⭐ — Disk check
`disk_check.sh [mount] [warn] [crit]` (defaults `/`, `80`, `90`): read usage with
`df --output=pcent "$mount" | tail -1 | tr -dc '0-9'` and print `OK`/`WARNING`/`CRITICAL`.
Exit codes: 0 OK, 1 WARNING, 2 CRITICAL (this is the **Nagios** convention!).

### Lab 2 ⭐ — File inspector
`inspect.sh <path>` reports: exists? file or directory or symlink? readable/writable/executable?
empty? size in bytes (files only, `stat -c %s`).

### Lab 3 ⭐⭐ — Tool checker
`require.sh` checks that `git`, `curl`, `docker`, `python3`, `jq` are installed (`command -v`),
prints ✅/❌ for each, and exits 1 if any are missing.

### Lab 4 ⭐⭐ — Environment guard
`guard.sh <env>` validates env with a regex (`^(dev|staging|prod)$`). For `prod`, require a
typed `yes` confirmation. Print which config file it would load: `config/<env>.yml`
(error if that file doesn't exist).

### Lab 5 ⭐⭐⭐ — Service control menu
`svc.sh {start|stop|restart|status} <service>` using `case`. Simulate state with a file
`/tmp/<service>.pid` (start creates it with `$$`, stop removes it, status checks it).
`restart` must call stop then start. Unknown commands print usage.

---

## ✅ Checkpoint
- [ ] I use `[[ ]]` with spaces, `-eq`/`-gt` for numbers, `==` for strings
- [ ] I know the file tests `-f -d -e -x -s`
- [ ] I can use a command's exit code directly in `if`
- [ ] I can write a `case` dispatcher

👉 Next: [Module 05 — Loops](../05-loops/README.md)
