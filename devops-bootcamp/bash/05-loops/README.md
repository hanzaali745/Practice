# Module 05 — Loops 🟢

## 🎯 Objectives
- Loop with `for` over lists, globs, ranges and command output
- Use C-style `for (( ))` loops
- Use `while` and `until` (great for retry/wait logic)
- Read files **line by line** correctly with `while IFS= read -r`
- Control loops with `break` and `continue`

## 🧠 Why DevOps engineers care
"For every server: run this." "For every log file: compress it." "Until the service is up:
wait." Loops turn a one-off command into fleet-wide automation.

Sample data: [`data/servers.txt`](data/servers.txt), [`data/inventory.csv`](data/inventory.csv)

---

## 📖 Lesson 5.1 — `for` over a list

```bash
for server in web-01 web-02 db-01; do
    echo "Checking $server"
done

servers="web-01 web-02 db-01"
for s in $servers; do echo "$s"; done        # unquoted on purpose: split on spaces
```

## 📖 Lesson 5.2 — `for` over files (globs)

```bash
for file in /var/log/*.log; do
    [[ -e $file ]] || continue           # if no match, the glob stays literal — skip it
    echo "$file: $(wc -l < "$file") lines"
done

for conf in config/*.{yml,yaml}; do echo "$conf"; done
```

> ❌ Never `for f in $(ls *.log)` — it breaks on spaces. Use the glob directly.

## 📖 Lesson 5.3 — Ranges & C-style

```bash
for i in {1..5}; do echo "$i"; done          # 1 2 3 4 5
for i in {0..20..5}; do echo "$i"; done      # 0 5 10 15 20
for i in {01..03}; do echo "web-$i"; done    # web-01 web-02 web-03

for (( i = 1; i <= 3; i++ )); do
    echo "Attempt $i"
done

n=4; for i in $(seq 1 "$n"); do echo "$i"; done   # when the range is in a variable
```

## 📖 Lesson 5.4 — `while` loops

```bash
count=1
while [[ $count -le 3 ]]; do
    echo "count=$count"
    (( count++ ))
done

# Wait for a service with timeout (VERY common in deploy scripts)
attempt=0
max=10
until curl -sf http://localhost:8080/health > /dev/null; do
    (( attempt++ ))
    if (( attempt >= max )); then
        echo "Service did not become healthy" >&2; exit 1
    fi
    echo "Waiting for service... ($attempt/$max)"
    sleep 2
done
echo "Service is up!"
```

`until` = loop while the condition is **false** (opposite of `while`).

Infinite loop (for monitors/daemons):
```bash
while true; do
    date; uptime
    sleep 5
done
```

## 📖 Lesson 5.5 — Reading a file line by line ✅ (the correct way)

```bash
while IFS= read -r line; do
    echo "Line: $line"
done < data/servers.txt
```

- `IFS=` keeps leading/trailing spaces
- `-r` keeps backslashes literal
- `< file` feeds the file into the loop

Skip comments/blank lines and split fields:

```bash
while IFS=, read -r name ip env role; do
    [[ $name == "name" ]] && continue          # skip CSV header
    [[ -z $name || $name == \#* ]] && continue # skip blanks/comments
    echo "$name ($ip) is a $role server in $env"
done < data/inventory.csv
```

Reading command output:
```bash
while IFS= read -r user; do
    echo "user: $user"
done < <(cut -d: -f1 /etc/passwd | head -5)     # process substitution
```

> ⚠️ `cmd | while read ...` runs the loop in a **subshell** — variables set inside are lost
> afterwards. Use `done < <(cmd)` when you need them later.

## 📖 Lesson 5.6 — `break` & `continue`

```bash
for port in 22 80 443 8080 3306; do
    [[ $port -eq 8080 ]] && continue      # skip 8080
    [[ $port -eq 3306 ]] && break         # stop at 3306
    echo "port $port"
done
```

## 📖 Lesson 5.7 — Running commands on many servers (preview)

```bash
while IFS= read -r host; do
    echo "== $host =="
    ssh -n -o ConnectTimeout=5 "$host" 'uptime' || echo "  unreachable"
done < data/servers.txt
```
(`ssh -n` stops ssh from eating the rest of the file from stdin!)

---

## ⚠️ Common mistakes
- `for f in $(ls)` or `for line in $(cat file)` — breaks on spaces; use globs / `while read`
- Forgetting `-r` and `IFS=` in `read`
- Infinite `while` loops with no `sleep` → 100% CPU
- Variables lost after `cmd | while read` (subshell)

---

## 🧪 Labs

### Lab 1 ⭐ — Multiplication of builds
Print `Build #1` … `Build #10` with a C-style loop, marking every 5th as `(release)`.

### Lab 2 ⭐ — Bulk file creator
Create `logs/app-01.log` … `logs/app-20.log` using brace ranges, each containing one line
with its own name and the date. Then loop over them with a glob and print each line count.

### Lab 3 ⭐⭐ — Inventory reader
Read `data/inventory.csv` with `while IFS=, read -r`, skip header/comments/blank lines, print
a formatted table, and at the end print the number of servers per environment
(use counters; you'll learn associative arrays in Module 07).

### Lab 4 ⭐⭐ — Ping sweep
Read `data/servers.txt` (ignore comments/blank lines) and check each host with
`ping -c1 -W1` (or `getent hosts` if ping is not available). Print UP/DOWN and a summary.

### Lab 5 ⭐⭐⭐ — Wait-for-it
`wait_for.sh <host> <port> [timeout]` waits until a TCP port is open, using
`timeout 1 bash -c "</dev/tcp/$host/$port"` in an `until` loop, printing progress.
Exit 0 when open, 1 when the timeout (default 30s) is reached. (This is used in Docker
entrypoints to wait for databases!)

---

## ✅ Checkpoint
- [ ] I loop over files with globs, never `$(ls)`
- [ ] I read files with `while IFS= read -r line; do ...; done < file`
- [ ] I can write a retry/wait loop with a timeout

👉 Next: [Module 06 — Functions](../06-functions/README.md)
