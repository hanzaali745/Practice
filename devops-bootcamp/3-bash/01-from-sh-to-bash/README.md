# Bash Module 01 — From sh to Bash 🟡

## 🎯 Objectives
- Know which Bash version you have and how to start a Bash script
- Replace `[ ]` with the safer, more powerful `[[ ]]`
- Do maths and comparisons with `(( ))`
- Count with `{1..10}` and C-style `for (( ))` loops
- Use `read -p`, `read -s`, here-strings `<<<` and process substitution `< <(...)`
- Upgrade Phase 2 scripts to clean, modern Bash

## 🧠 Why DevOps engineers care
Most servers you'll manage have Bash, and most team scripts are written in Bash. These features
make scripts shorter, safer and easier to read. You already know the foundation — now level up.

---

## 📖 Lesson 1.1 — Your Bash

```bash
bash --version            # Ubuntu 24.04 ships Bash 5.2
echo "$BASH_VERSION"
echo "$0"                 # your terminal is bash
```

Every Bash script starts like this:
```bash
#!/usr/bin/env bash
```
Run it with `bash script.sh` or `./script.sh`. **Never** with `sh script.sh` — that uses `dash`,
which doesn't understand Bash features and gives confusing errors like `[[: not found`.

## 📖 Lesson 1.2 — `[[ ]]`: the better test

```bash
name="web-07"
file="my report.txt"

[[ $name == "web-07" ]]          # == works (and quoting inside [[ ]] is optional for variables)
[[ $name == web-* ]]             # ✅ wildcard pattern (right side UNquoted)
[[ $name =~ ^web-([0-9]+)$ ]]    # ✅ regular expression
echo "${BASH_REMATCH[1]}"        # 07  ← the part captured by ( )
[[ -f $file && -r $file ]]       # ✅ && and || INSIDE the brackets
[[ -z $empty_var ]]              # no crash even when unset/empty
```

Compared to Phase 2:

| POSIX `[ ]` | Bash `[[ ]]` |
|-------------|--------------|
| `[ "$a" = "b" ]` | `[[ $a == b ]]` |
| `[ -f "$f" ] && [ -r "$f" ]` | `[[ -f $f && -r $f ]]` |
| `case $h in web-*) ...` | `[[ $h == web-* ]]` |
| `echo "$v" \| grep -Eq '^[0-9]+$'` | `[[ $v =~ ^[0-9]+$ ]]` |

> ⚠️ Inside `[[ ]]`, `<` and `>` compare **text** alphabetically. For numbers use `-lt`/`-gt` or `(( ))`.

## 📖 Lesson 1.3 — `(( ))`: maths that reads like maths

```bash
count=0
(( count++ ))              # add 1
(( count += 5 ))
(( total = count * 2 ))
echo "$count $total"       # 6 12

cpu=92
if (( cpu > 90 )); then echo "CPU critical"; fi
(( cpu >= 80 && cpu < 90 )) && echo "CPU warning"
echo $(( 2 ** 10 ))        # 1024  (power — Bash only)
```

Inside `(( ))` you don't need `$` before variable names.

> ⚠️ One trap you'll meet in Module 04: `(( count++ ))` when `count` is 0 has exit status 1,
> which stops a `set -e` script. Use `(( ++count ))` or `count=$((count + 1))` in strict scripts.

## 📖 Lesson 1.4 — Easy counting loops

```bash
for i in {1..5}; do echo "$i"; done                 # 1 2 3 4 5
for i in {0..20..5}; do echo "$i"; done             # 0 5 10 15 20
for host in web-{01..03}; do echo "$host"; done     # web-01 web-02 web-03
mkdir -p app/{config,logs,scripts}                  # brace expansion works everywhere

for (( i = 1; i <= 3; i++ )); do                     # C-style loop
    echo "Attempt $i"
done
```

> `{1..$n}` does **not** work with a variable. Use `for (( i = 1; i <= n; i++ ))` instead.

## 📖 Lesson 1.5 — Better `read`

```bash
read -r -p "Server name: " server                       # prompt on the same line
read -r -s -p "Password: " password; echo               # -s = hidden typing
read -r -t 10 -p "Continue? [y/N] " answer || answer="N" # -t = timeout in seconds
read -r -n 1 -p "Press any key..." ; echo               # -n 1 = one key only
```

## 📖 Lesson 1.6 — Here-strings and process substitution

**Here-string `<<<`** — feed a variable into a command:
```bash
version="2.13.4"
IFS=. read -r major minor patch <<< "$version"
echo "major=$major minor=$minor patch=$patch"
grep -c "web" <<< "$server_list"
```

**Process substitution `< <(command)`** — loop over command output **without** losing variables
(this fixes the "pipe trap" from Shell Module 05):
```bash
count=0
while IFS= read -r user; do
    (( ++count ))
done < <(cut -d: -f1 /etc/passwd)
echo "$count users"        # ✅ works! (with "cut ... | while read" it would print 0)
```

Compare two command outputs as if they were files:
```bash
diff <(ssh web-01 cat /etc/nginx/nginx.conf) <(ssh web-02 cat /etc/nginx/nginx.conf)
diff <(sort list1.txt) <(sort list2.txt)
```

## 📖 Lesson 1.7 — More handy Bash extras

```bash
content=$(< /etc/hostname)        # read a file without cat
echo "Line: $LINENO"              # current line number (great in error messages)
echo "Took ${SECONDS}s"           # seconds since the script started
echo $(( RANDOM % 100 ))          # random number 0-99
cmd &> /dev/null                  # stdout AND stderr to the same place (sh: > /dev/null 2>&1)
printf -v padded "%05d" 42        # print INTO a variable → 00042
```

## 📖 Lesson 1.8 — Upgrade example

Phase 2 (POSIX):
```sh
i=1
while [ "$i" -le 3 ]; do
    if [ "$(echo "$host" | cut -c1-3)" = "web" ] && [ -f "/etc/$host.conf" ]; then
        echo "$i: web config found"
    fi
    i=$((i + 1))
done
```

Phase 3 (Bash):
```bash
for (( i = 1; i <= 3; i++ )); do
    if [[ $host == web* && -f /etc/$host.conf ]]; then
        echo "$i: web config found"
    fi
done
```

Same logic — shorter, clearer, fewer chances for quoting mistakes.

---

## ⚠️ Common mistakes
- Running a Bash script with `sh script.sh` → `[[: not found`, `Syntax error: "(" unexpected`
- Quoting the pattern side: `[[ $h == "web-*" ]]` matches only the literal text `web-*`
- `{1..$n}` with a variable (doesn't expand)
- Using `<` / `>` in `[[ ]]` for numbers

---

## 🧪 Labs
Work in `~/Practice/devops-bootcamp/my-work/bash/`. Check every script with `shellcheck`.

### Lab 1 ⭐ — Upgrade a script
Take your Shell Module 04 `disk_check.sh` and rewrite it in Bash with `[[ ]]` and `(( ))`.
Keep the same exit codes (0/1/2/3).

### Lab 2 ⭐ — Hostname classifier
`classify.sh <hostname>...` — for each name print `web`, `database`, `cache` or `unknown` using
`[[ $h == pattern ]]`, and print the number from names like `web-07` using `=~` and `BASH_REMATCH`.

### Lab 3 ⭐⭐ — Interactive setup
`setup.sh` asks (with `read -p`) for app name, environment (default `dev`), and a hidden DB password
(`read -s`). Validate the app name with a regex (`^[a-z][a-z0-9-]{2,20}$`) and loop until it's valid.
Print a summary with the password masked as `****`.

### Lab 4 ⭐⭐ — Counting with process substitution
Count how many users in `/etc/passwd` have `/bin/bash` as their shell and how many have
`nologin`, using a `while read` loop over `< <(...)`. Print both counts **after** the loop.

### Lab 5 ⭐⭐⭐ — Version compare
`vercmp.sh A B` prints `A < B`, `A = B` or `A > B` for versions like `1.10.2` vs `1.9.15`.
Split with `IFS=. read -r` and compare each part with `(( ))`. (Hint: string comparison gets
`1.10` vs `1.9` wrong — that's the whole point!)

---

## ✅ Checkpoint
- [ ] I start Bash scripts with `#!/usr/bin/env bash` and never run them with `sh`
- [ ] I use `[[ ]]` with patterns and `=~` with `BASH_REMATCH`
- [ ] I use `(( ))` for maths and numeric comparisons
- [ ] I can loop with `{1..10}` and `for (( ))`
- [ ] I use `< <(cmd)` when I need variables after a `while read` loop

👉 Next: [Module 02 — Arrays & String Manipulation](../02-arrays-and-strings/README.md)
