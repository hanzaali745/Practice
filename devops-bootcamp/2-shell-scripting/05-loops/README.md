# Shell Module 05 — Loops 🟢

## 🎯 Objectives
- Loop with `for` over lists, files and number sequences
- Use `while` and `until` (perfect for "retry" and "wait until ready")
- Read a file **line by line** the correct way
- Control loops with `break` and `continue`

## 🧠 Why DevOps engineers care
"For every server: run this." "For every log: compress it." "Until the database is up: wait."
Loops turn one command into fleet-wide automation.

Sample data: [`data/servers.txt`](data/servers.txt), [`data/inventory.csv`](data/inventory.csv)

---

## 📖 Lesson 5.1 — `for` over a list

```sh
for server in web-01 web-02 db-01; do
    echo "Checking $server"
done
```
Output:
```
Checking web-01
Checking web-02
Checking db-01
```

Read it as: *"for each `server` in this list, do the commands between `do` and `done`"*.

## 📖 Lesson 5.2 — `for` over files

```sh
for file in /var/log/*.log; do
    [ -e "$file" ] || continue          # if nothing matched, skip (see below)
    echo "$file has $(wc -l < "$file") lines"
done
```

- `*.log` is a **glob**: the shell replaces it with every matching file name.
- If **no** file matches, the loop gets the literal text `/var/log/*.log` — that's why we check `[ -e "$file" ]`.

> ❌ Never write `for f in $(ls *.log)` — it breaks on file names with spaces.

## 📖 Lesson 5.3 — Counting loops

POSIX sh has no `{1..10}` (that's Bash). Use `seq` or a `while` counter:

```sh
for i in $(seq 1 5); do echo "$i"; done        # 1 2 3 4 5
for i in $(seq 0 5 20); do echo "$i"; done     # 0 5 10 15 20  (start step end)
for i in $(seq -w 1 10); do echo "web-$i"; done  # web-01 ... web-10  (-w = zero-pad)

i=1
while [ "$i" -le 3 ]; do                       # works with no extra tools at all
    echo "Attempt $i"
    i=$((i + 1))
done
```

## 📖 Lesson 5.4 — `while` and `until` (retry & wait)

`while` repeats **while** the condition is true. `until` repeats **until** it becomes true.

Wait for a web service — you'll see this in almost every deploy script:

```sh
attempt=0
max=10
until curl -sf http://localhost:8080/health > /dev/null; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge "$max" ]; then
        echo "Service did not become healthy" >&2
        exit 1
    fi
    echo "Waiting for service... ($attempt/$max)"
    sleep 2
done
echo "Service is up!"
```

A forever loop (for simple monitors) — stop it with `Ctrl+C`:
```sh
while true; do
    date
    uptime
    sleep 5            # ALWAYS sleep in a forever loop, or it eats 100% CPU
done
```

## 📖 Lesson 5.5 — Reading a file line by line ✅

The correct pattern — memorise it:

```sh
while IFS= read -r line; do
    echo "Line: $line"
done < data/servers.txt
```

- `< data/servers.txt` feeds the file into the loop
- `IFS=` keeps spaces at the start/end of lines
- `-r` keeps backslashes as they are

Skip comments and empty lines, and split CSV columns:

```sh
while IFS=, read -r name ip env role; do
    case "$name" in
        ''|'#'*|name) continue ;;               # skip blank lines, comments, and the header
    esac
    echo "$name ($ip) is a $role server in $env"
done < data/inventory.csv
```

`IFS=,` tells `read` to split each line at commas into `name`, `ip`, `env`, `role`.

Looping over a command's output:
```sh
cut -d: -f1 /etc/passwd | head -5 | while IFS= read -r user; do
    echo "user: $user"
done
```

> ⚠️ **Pipe trap:** with `cmd | while read ...`, the loop runs in a **sub-shell**. Variables you
> change inside are **lost** after `done`. If you need a counter afterwards, write the
> command output to a temp file first and use `done < "$tmpfile"`.

## 📖 Lesson 5.6 — `break` and `continue`

```sh
for port in 22 80 443 8080 3306; do
    if [ "$port" -eq 8080 ]; then continue; fi    # skip just this one
    if [ "$port" -eq 3306 ]; then break; fi       # stop the whole loop
    echo "port $port"
done
# port 22, port 80, port 443
```

## 📖 Lesson 5.7 — Run a command on many servers (preview)

```sh
while IFS= read -r host; do
    echo "== $host =="
    ssh -n -o ConnectTimeout=5 "$host" uptime || echo "  unreachable"
done < data/servers.txt
```
`ssh -n` matters: without it, ssh "eats" the rest of the file and the loop stops after one host.

---

## ⚠️ Common mistakes
- `for f in $(ls)` or `for line in $(cat file)` → breaks on spaces. Use globs and `while read`
- Forgetting `IFS=` and `-r` in `read`
- A `while true` loop with no `sleep`
- Expecting a counter changed inside `cmd | while read` to survive after the loop
- Using Bash-only `{1..10}` or `for ((i=0; ...))` in an `sh` script

---

## 🧪 Labs
Work in `my-work/shell/`. The data files are in this module's `data/` folder.

### Lab 1 ⭐ — Build numbers
Print `Build #1` … `Build #10`. Mark every 5th build as `(release)`. (Hint: `$((i % 5))`.)

### Lab 2 ⭐ — Bulk file creator
Create `logs/app-01.log` … `logs/app-20.log` (use `seq -w`), each containing its own name and
today's date. Then loop over `logs/*.log` and print the line count of each.

### Lab 3 ⭐⭐ — Inventory reader
Read `data/inventory.csv`, skip the header/comments/blank lines, print a neat table with `printf`,
then print how many servers are in each environment (use 3 counter variables and `case`).

### Lab 4 ⭐⭐ — Ping sweep
Read `data/servers.txt` (skip comments and blank lines). Check each host with `ping -c1 -W1`.
Print `UP`/`DOWN` per host and a summary at the end.

### Lab 5 ⭐⭐⭐ — Wait-for-port
`wait_for.sh <host> <port> [timeout]` waits until a TCP port accepts connections, using
`nc -z -w1 "$host" "$port"` in an `until` loop and printing progress. Exit 0 when open,
exit 1 after the timeout (default 30 seconds). Docker entrypoints use exactly this to wait
for a database.

Test it: in one terminal run `python3 -m http.server 8000`, in another `sh wait_for.sh localhost 8000`.

---

## ✅ Checkpoint
- [ ] I loop over files with globs, never `$(ls)`
- [ ] I can write `while IFS= read -r line; do ...; done < file` from memory
- [ ] I can write a wait/retry loop with a timeout
- [ ] I know `{1..10}` is Bash-only and use `seq` in sh

👉 Next: [Module 06 — Functions](../06-functions/README.md)
