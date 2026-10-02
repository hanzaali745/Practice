# Module 08 — Text Processing: Pipes, Redirection, grep, sed, awk 🟡

## 🎯 Objectives
- Control input/output with **redirection** (`>`, `>>`, `2>`, `&>`, `<`)
- Chain tools with **pipes** `|`
- Use the core toolkit: `cut`, `sort`, `uniq`, `wc`, `tr`, `head`, `tail`, `tee`, `xargs`
- Search with **grep**, edit with **sed**, analyse with **awk**
- Peek at **jq** for JSON

## 🧠 Why DevOps engineers care
This is the Unix superpower. One pipeline can answer "which IPs are hammering our login
endpoint?" in 5 seconds during an incident — no code editor needed. Every senior engineer
is fast with `grep | awk | sort | uniq -c | sort -nr | head`.

Sample data in [`data/`](data/): `access.log` (nginx), `app.log`, `app.conf`.

---

## 📖 Lesson 8.1 — Standard streams & redirection

Every process has 3 streams: **stdin (0)**, **stdout (1)**, **stderr (2)**.

```bash
cmd > out.txt          # stdout to file (overwrite)
cmd >> out.txt         # stdout append
cmd 2> err.txt         # stderr to file
cmd > all.txt 2>&1     # both to the same file (order matters!)
cmd &> all.txt         # same, bash shortcut
cmd > /dev/null 2>&1   # silence everything
cmd < input.txt        # file as stdin
echo "error" >&2       # write to stderr (for your error messages)
```

## 📖 Lesson 8.2 — Pipes

`|` sends the stdout of one command into the stdin of the next:

```bash
cat data/access.log | wc -l            # works, but...
wc -l < data/access.log                # ...no need for cat ("useless use of cat")
ps aux | grep nginx
history | tail -20
```

`tee` = write to a file **and** keep passing data on:
```bash
./deploy.sh 2>&1 | tee deploy.log      # see output live AND save it
```

## 📖 Lesson 8.3 — The core toolkit

```bash
cut -d' ' -f1 data/access.log           # field 1 split by space (IPs)
cut -d= -f2 data/app.conf               # values of key=value
cut -c1-10 file                         # characters 1–10

sort file                               # alphabetical
sort -n / -nr                           # numeric / numeric reverse
sort -k2 -nr                            # by 2nd column, numeric, reverse
sort -u                                 # unique
sort -t, -k3 file.csv                   # comma-separated, by column 3

uniq                                    # remove ADJACENT duplicates (sort first!)
uniq -c                                 # count them

wc -l / -w / -c                         # lines / words / bytes
tr 'a-z' 'A-Z'                          # translate chars
tr -d '\r'                              # delete chars (fix Windows line endings)
tr -s ' '                               # squeeze repeated spaces
head -n 5 / tail -n 5 / tail -f
```

⭐ **The most famous DevOps one-liner** — top 5 IPs:
```bash
cut -d' ' -f1 data/access.log | sort | uniq -c | sort -nr | head -5
```

`xargs` = turn input lines into arguments:
```bash
find /tmp -name "*.tmp" -mtime +7 | xargs -r rm -f
echo "web-01 web-02" | xargs -n1 echo "deploying"
find . -name "*.log" -print0 | xargs -0 gzip          # safe with spaces
```

## 📖 Lesson 8.4 — grep (search)

```bash
grep "ERROR" data/app.log               # lines containing ERROR
grep -i "error" file                    # case-insensitive
grep -v "INFO" file                     # INVERT: lines NOT matching
grep -c "ERROR" file                    # count
grep -n "ERROR" file                    # with line numbers
grep -r "DB_HOST" /etc/app/             # recursive in a directory
grep -l "password" *.conf               # only file names
grep -w "port" file                     # whole word only
grep -A2 -B1 "CRITICAL" file            # 2 lines After, 1 Before (context)
grep -E "ERROR|CRITICAL" file           # extended regex (alternation)
grep -oE "[0-9]{3} [0-9]+$" file        # print ONLY the matching part
grep -q "pattern" file && echo found    # quiet — just exit code
grep -v '^#' data/app.conf | grep -v '^$'   # strip comments & blank lines
```

## 📖 Lesson 8.5 — sed (stream editor)

```bash
sed 's/staging/production/' file        # replace first match per line (prints result)
sed 's/staging/production/g' file       # replace ALL matches per line
sed -i 's/LOG_LEVEL=debug/LOG_LEVEL=info/' data/app.conf   # -i = edit file IN PLACE
sed -i.bak 's/a/b/g' file               # in place, keeping file.bak backup ✅
sed 's#/var/log#/data/logs#g' file      # any delimiter — handy for paths
sed -n '5,10p' file                     # print only lines 5–10
sed '/^#/d' file                        # delete comment lines
sed '/^$/d' file                        # delete empty lines
sed 's/^/  /' file                      # indent every line
sed -E 's/(DB_PASSWORD=).*/\1******/' data/app.conf   # mask secrets (capture group \1)
sed -i "s/^APP_ENV=.*/APP_ENV=${ENV}/" data/app.conf   # double quotes to use a variable
```

> ⚠️ On macOS, `sed -i` needs an argument: `sed -i '' 's/a/b/' file`. `sed -i.bak` works on both.

## 📖 Lesson 8.6 — awk (columns & mini-programs)

awk splits each line into fields `$1 $2 ... $NF` (NF = number of fields, NR = line number).

```bash
awk '{print $1}' data/access.log                     # first column
awk '{print $1, $9}' data/access.log                 # IP and status
awk -F= '{print $1}' data/app.conf                   # custom separator
awk '$9 >= 500' data/access.log                      # filter: status >= 500
awk '$9 == 401 {print $1}' data/access.log           # filter + print
awk 'NR > 1' file.csv                                # skip header line
awk '{print NR": "$0}' file                          # number lines ($0 = whole line)
awk '{print $NF}' file                               # last field

# Sum & average
awk '{bytes += $10} END {print "total bytes:", bytes}' data/access.log
awk '{sum += $10; n++} END {printf "avg %.1f bytes\n", sum/n}' data/access.log

# Group & count (awk associative arrays)
awk '{count[$9]++} END {for (s in count) print s, count[s]}' data/access.log

# Formatted report
awk '{printf "%-15s %s\n", $1, $9}' data/access.log
```

## 📖 Lesson 8.7 — jq for JSON (bonus)

`jq` is "sed/awk for JSON" — essential with cloud CLIs (`aws`, `kubectl -o json`, `gh`).

```bash
echo '{"name":"api","replicas":3,"tags":["web","prod"]}' | jq '.replicas'      # 3
echo '{"name":"api","tags":["web","prod"]}' | jq -r '.tags[]'                   # web / prod
curl -s https://api.github.com/repos/python/cpython | jq '{stars: .stargazers_count, forks: .forks_count}'
kubectl get pods -o json | jq -r '.items[] | select(.status.phase != "Running") | .metadata.name'
```

---

## ⚠️ Common mistakes
- `uniq` without `sort` first (only removes *adjacent* duplicates)
- `sed -i` without testing first — run without `-i`, check the output, then add `-i`
- Single quotes prevent variable expansion: `sed "s/x/$VAR/"` needs double quotes
- `cmd 2>&1 > file` — wrong order; it should be `cmd > file 2>&1`

---

## 🧪 Labs
All labs use files in `data/`. Solutions are one-liners in [`solutions/labs.sh`](solutions/labs.sh).

### Lab 1 ⭐ — grep basics (`app.log`)
1. All ERROR lines  2. Count of ERROR + CRITICAL  3. Lines NOT INFO  4. Lines for `db-01` with line numbers

### Lab 2 ⭐ — Config cleanup (`app.conf`)
1. Print config without comments/blank lines  2. Print only the keys
3. Print the value of `DB_PORT`  4. Print the file with `DB_PASSWORD` masked as `******`

### Lab 3 ⭐⭐ — sed edits (work on a copy!)
`cp data/app.conf /tmp/app.conf`, then with `sed -i`: change `APP_ENV` to `production`,
`LOG_LEVEL` to `info`, `LISTEN_PORT` to `9090`, and uncomment `FEATURE_X`. Show a `diff`.

### Lab 4 ⭐⭐ — Access log analysis (`access.log`)
1. Total requests  2. Top 3 IPs  3. Requests per status code  4. All 5xx lines
5. Total bytes served  6. Most requested path  7. Requests per minute (hint: cut the timestamp)

### Lab 5 ⭐⭐⭐ — Security report
Single script `security_report.sh` that prints IPs with ≥3 `401` responses (brute-force suspects),
any non-browser user agents, and the percentage of error responses (status ≥ 400) using awk.

---

## ✅ Checkpoint
- [ ] I know `>`, `>>`, `2>&1`, `&>`, `|`, `tee`
- [ ] I can write `cut | sort | uniq -c | sort -nr | head` from memory
- [ ] I can filter with grep, replace with sed, and sum/group with awk

👉 Next: [Module 09 — Error Handling & Debugging](../09-error-handling/README.md)
