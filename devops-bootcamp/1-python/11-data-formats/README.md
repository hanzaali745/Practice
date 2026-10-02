# Python Module 11 — Data Formats & Regex 🔴

## 🎯 Objectives
- Read/write **JSON** (APIs, AWS, Terraform output)
- Read/write **YAML** (Kubernetes, Ansible, GitHub Actions, Docker Compose)
- Read/write **CSV** (reports, inventories)
- Use **regular expressions** to extract data from logs

## 🧠 Why DevOps engineers care
DevOps runs on structured text. Kubernetes manifests and CI pipelines are YAML.
Every cloud API returns JSON. Managers want CSV reports. Nginx/Apache logs need regex.
After this module you can read and transform **all** of them.

Sample data is in [`data/`](data/).

---

## 📖 Lesson 11.1 — JSON

JSON ↔ Python mapping: object ↔ `dict`, array ↔ `list`, string ↔ `str`,
number ↔ `int/float`, `true/false` ↔ `True/False`, `null` ↔ `None`.

```python
import json

# File → Python
with open("data/servers.json") as f:
    data = json.load(f)
for s in data["servers"]:
    print(s["name"], s["ip"])

# String → Python (e.g. API response or command output)
obj = json.loads('{"status": "ok", "replicas": 3}')

# Python → string
text = json.dumps(obj, indent=2, sort_keys=True)

# Python → file
with open("out.json", "w") as f:
    json.dump(data, f, indent=2)
```

Parsing a CLI's JSON output (very common!):
```python
import json, subprocess
out = subprocess.run(["docker", "ps", "--format", "{{json .}}"], capture_output=True, text=True).stdout
containers = [json.loads(line) for line in out.splitlines()]
```

## 📖 Lesson 11.2 — YAML

YAML needs a library: `pip install pyyaml`.

> 🐧 **Ubuntu:** run `pip` only inside your venv (`source ~/venvs/devops/bin/activate`). If you did Step 0, this is already installed.

```python
import yaml

with open("data/deployment.yaml") as f:
    manifest = yaml.safe_load(f)          # ✅ ALWAYS safe_load (yaml.load can run code!)

print(manifest["metadata"]["name"])        # api
print(manifest["spec"]["replicas"])        # 2
for c in manifest["spec"]["template"]["spec"]["containers"]:
    print(c["name"], c["image"])

manifest["spec"]["replicas"] = 4
with open("deployment-scaled.yaml", "w") as f:
    yaml.safe_dump(manifest, f, sort_keys=False)

# Multiple documents separated by ---
with open("multi.yaml") as f:
    docs = list(yaml.safe_load_all(f))
```

## 📖 Lesson 11.3 — CSV

```python
import csv

with open("data/users.csv", newline="") as f:
    for row in csv.DictReader(f):          # each row is a dict keyed by header
        print(row["username"], row["team"])

rows = [{"host": "web-01", "cpu": 45}, {"host": "db-01", "cpu": 91}]
with open("report.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["host", "cpu"])
    writer.writeheader()
    writer.writerows(rows)
```

## 📖 Lesson 11.4 — Regular expressions (regex)

Regex = a mini-language for **patterns** in text.

| Pattern | Matches |
|---------|---------|
| `\d` | a digit | 
| `\w` | letter, digit or `_` |
| `\s` | whitespace |
| `.` | any character |
| `+` / `*` / `?` | 1+ / 0+ / 0 or 1 of previous |
| `{3}` / `{1,3}` | exactly 3 / 1 to 3 |
| `[abc]` / `[^abc]` | one of / not one of |
| `^` / `$` | start / end of line |
| `( )` | capture group |
| `(?P<name> )` | named group |

```python
import re

line = '10.0.0.5 - - [01/May/2024:10:00:03 +0000] "POST /api/login HTTP/1.1" 401 54'

# search: find the first match anywhere
m = re.search(r"\d{1,3}(\.\d{1,3}){3}", line)
print(m.group())                                   # 10.0.0.5

# findall: all matches
print(re.findall(r"\d{3}", "codes 200 404 500"))  # ['200', '404', '500']

# named groups — the pro way to parse logs
LOG_RE = re.compile(
    r'(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] "(?P<method>\w+) (?P<path>\S+) [^"]+" '
    r"(?P<status>\d{3}) (?P<size>\d+)"
)
m = LOG_RE.match(line)
if m:
    print(m.group("ip"), m.group("status"), m.groupdict())

# sub: search & replace — e.g. mask secrets before logging!
print(re.sub(r"(password=)\S+", r"\1****", "user=bob password=hunter2"))
```

> 💡 Always use **raw strings** `r"..."` for regex. Test patterns on https://regex101.com (pick Python flavour).

## ⚠️ Common mistakes
- `yaml.load()` without a Loader on untrusted files → code execution risk. Use `safe_load`
- Forgetting `newline=""` when opening CSV files → blank lines on Windows
- Greedy regex: `".*"` matches as much as possible; use `.*?` for minimal
- Using regex when `split()` or `json` would be simpler

---

## 🧪 Labs

### Lab 1 ⭐ — JSON inventory
From `data/servers.json`: print prod servers with CPU > 80, and write a new
file `prod_servers.json` containing only prod servers.

### Lab 2 ⭐⭐ — Kubernetes manifest auditor
Load `data/deployment.yaml` and report:
- containers using the `:latest` tag (bad practice!) or no tag
- containers missing resource limits
- warn if `replicas < 3` for a production app
Then write a fixed copy with `replicas: 3`.

### Lab 3 ⭐⭐ — CSV → JSON
Convert `data/users.csv` to JSON grouped by team, with `sudo` as a real boolean:
`{"platform": [{"username": "alice", "sudo": true, ...}], ...}`

### Lab 4 ⭐⭐⭐ — Access log analyser
Parse `data/access.log` with a named-group regex and print:
- requests per status code
- top IP addresses
- IPs with ≥ 3 failed logins (`401`) → possible brute force 🚨
- write all 5xx errors to `server_errors.csv`

---

## ✅ Checkpoint
- [ ] I can load/dump JSON and YAML, and I always use `safe_load`
- [ ] I can read and write CSV with `DictReader`/`DictWriter`
- [ ] I can write a regex with named groups to parse a log line

👉 Next: [Module 12 — APIs & Cloud](../12-apis-and-cloud/README.md)
