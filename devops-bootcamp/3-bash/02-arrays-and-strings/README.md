# Bash Module 02 — Arrays & String Manipulation 🟡

## 🎯 Objectives
- Use **indexed arrays** (lists) and **associative arrays** (dictionaries)
- Loop over arrays safely
- Manipulate strings with **parameter expansion** — no external commands needed
- Split strings into arrays with `IFS` and `read -a`, and read files with `mapfile`

## 🧠 Why DevOps engineers care
Lists of servers, maps of service → port, parsing image tags and file names, stripping
extensions, building backup names. Parameter expansion does it all **inside Bash**,
fast, without calling `sed`/`cut`/`basename` thousands of times.

> These are **Bash features** (not POSIX `sh`). Associative arrays need Bash 4+.

---

## 📖 Lesson 2.1 — Indexed arrays

```bash
servers=("web-01" "web-02" "db-01")

echo "${servers[0]}"        # web-01
echo "${servers[-1]}"       # db-01 (last, bash 4.3+)
echo "${servers[@]}"        # all elements
echo "${#servers[@]}"       # 3 (count)
echo "${!servers[@]}"       # 0 1 2 (indexes)
echo "${servers[@]:1:2}"    # slice: web-02 db-01

servers+=("cache-01")       # append
servers[1]="web-02b"        # replace
unset 'servers[0]'          # remove (leaves a gap in indexes!)
servers=("${servers[@]}")   # re-index

for s in "${servers[@]}"; do      # ✅ ALWAYS quote "${arr[@]}"
    echo "server: $s"
done

for i in "${!servers[@]}"; do     # with index
    echo "$i: ${servers[$i]}"
done
```

Build commands safely with arrays (great for optional flags!):
```bash
args=(-av --delete)
[[ ${DRY_RUN:-0} == 1 ]] && args+=(--dry-run)
rsync "${args[@]}" src/ dest/
```

## 📖 Lesson 2.2 — Associative arrays (dictionaries)

```bash
declare -A ports=(
    [nginx]=80
    [postgres]=5432
    [redis]=6379
)
ports[ssh]=22                       # add

echo "${ports[nginx]}"              # 80
echo "${!ports[@]}"                 # keys (unordered!)
echo "${ports[@]}"                  # values
echo "${#ports[@]}"                 # count

for svc in "${!ports[@]}"; do
    echo "$svc -> ${ports[$svc]}"
done

[[ -v ports[mysql] ]] || echo "mysql not defined"   # key exists? (bash 4.2+)

declare -A count=()                 # counting pattern
for level in INFO ERROR INFO WARN ERROR INFO; do
    (( ++count[$level] ))
done
for k in "${!count[@]}"; do echo "$k=${count[$k]}"; done
```

## 📖 Lesson 2.3 — String length, substring, case

```bash
s="production"
echo "${#s}"          # 10 (length)
echo "${s:0:4}"       # prod (offset 0, length 4)
echo "${s:4}"         # uction
echo "${s: -3}"       # ion  (note the space before -)
echo "${s^^}"         # PRODUCTION
echo "${s^}"          # Production
v="WEB"; echo "${v,,}" # web
```

## 📖 Lesson 2.4 — Remove prefix/suffix (super useful!)

| Syntax | Removes | Mnemonic |
|--------|---------|----------|
| `${var#pattern}` | shortest match from the **start** | `#` is on the left of `$` on the keyboard |
| `${var##pattern}` | longest match from the start | |
| `${var%pattern}` | shortest match from the **end** | `%` is on the right |
| `${var%%pattern}` | longest match from the end | |

```bash
path="/var/log/nginx/access.log.gz"
echo "${path##*/}"        # access.log.gz        (like basename)
echo "${path%/*}"         # /var/log/nginx       (like dirname)
echo "${path%.gz}"        # /var/log/nginx/access.log
file="${path##*/}"
echo "${file%%.*}"        # access               (name without ANY extension)
echo "${file#*.}"         # log.gz               (all extensions)

image="registry.example.com/team/api:v2.3.1"
echo "${image##*:}"       # v2.3.1    (tag)
echo "${image%:*}"        # registry.example.com/team/api
```

## 📖 Lesson 2.5 — Search & replace

```bash
s="web_server_01"
echo "${s/_/-}"           # web-server_01   (first match)
echo "${s//_/-}"          # web-server-01   (all matches)
echo "${s/#web/api}"      # api_server_01   (only at start)
echo "${s/%01/02}"        # web_server_02   (only at end)
echo "${s//[0-9]/}"       # web_server_     (delete digits)
```

## 📖 Lesson 2.6 — Splitting strings into arrays

```bash
csv="web-01,web-02,db-01"
IFS=, read -r -a hosts <<< "$csv"     # <<< = "here string"
echo "${#hosts[@]} hosts: ${hosts[1]}"

version="2.13.4"
IFS=. read -r major minor patch <<< "$version"
echo "major=$major minor=$minor patch=$patch"

joined=$(IFS=,; echo "${hosts[*]}")   # join array with a delimiter
```

## 📖 Lesson 2.7 — Reading a file into an array

```bash
mapfile -t lines < /etc/hosts         # -t strips newlines (also called readarray)
echo "Read ${#lines[@]} lines; first: ${lines[0]}"

mapfile -t users < <(cut -d: -f1 /etc/passwd)
```

---

## ⚠️ Common mistakes
- `${arr[@]}` without quotes → elements with spaces break
- `$arr` only gives the **first** element
- Forgetting `declare -A` → the "associative" array becomes a normal one with index 0
- Assuming associative array keys come out in order (they don't — sort them)

---

## 🧪 Labs

### Lab 1 ⭐ — Server array
Create an array of 5 servers. Print the count, first, last, a numbered list,
add 2 servers, remove the 2nd one, re-index, and print again.

### Lab 2 ⭐⭐ — Service port map
Create an associative array of 6 service→port pairs. Print them **sorted by service name**
as a table, then check if ports `22`, `3306`, `8080` belong to any service (reverse lookup).

### Lab 3 ⭐⭐ — Path & image dissector
Given `/opt/releases/api-service-v2.3.1.tar.gz` and `ghcr.io/acme/web-frontend:1.8.0-rc1`,
print: directory, file name, name without extension, version, registry, repository, tag —
using **only parameter expansion**.

### Lab 4 ⭐⭐ — Version bumper
`bump.sh <version> <major|minor|patch>` → `bump.sh 1.4.9 patch` prints `1.4.10`;
`minor` → `1.5.0`; `major` → `2.0.0`. Validate the input format with a regex.

### Lab 5 ⭐⭐⭐ — Log level counter
Count occurrences of each level in `../../1-python/07-files-and-errors/data/app.log` using an
associative array and `while read`, then print levels sorted by count (pipe into `sort -k2 -nr`).

---

## ✅ Checkpoint
- [ ] I always use `"${arr[@]}"` with quotes
- [ ] I can use `declare -A` for key/value data
- [ ] I can do basename/dirname/extension/replace with `#`, `%`, `/`, `//`

👉 Next: [Module 03 — Functions & Libraries](../03-functions-and-libraries/README.md)
