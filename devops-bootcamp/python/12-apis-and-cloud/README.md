# Module 12 — APIs & Cloud 🔴

## 🎯 Objectives
- Understand REST APIs: methods, status codes, headers, JSON bodies
- Call APIs with `requests` (and `urllib` when you can't install anything)
- Handle auth tokens, timeouts, retries and pagination
- Build a tiny HTTP health endpoint yourself
- Take your first steps with AWS `boto3`

## 🧠 Why DevOps engineers care
Everything in modern infrastructure has an API: AWS, GitHub, GitLab, Kubernetes,
Slack, PagerDuty, Grafana, Jenkins. Calling APIs from Python is how you automate
"click-ops" away — and how you build health checks and ChatOps bots.

---

## 📖 Lesson 12.1 — REST basics

| Method | Meaning | Example |
|--------|---------|---------|
| `GET` | read | list servers |
| `POST` | create | create a server |
| `PUT`/`PATCH` | replace / update | resize a server |
| `DELETE` | delete | terminate a server |

| Status | Meaning |
|--------|---------|
| `2xx` | success (`200 OK`, `201 Created`, `204 No Content`) |
| `3xx` | redirect |
| `4xx` | **your** fault (`400` bad request, `401` unauthenticated, `403` forbidden, `404` not found, `429` rate limited) |
| `5xx` | **server's** fault (`500`, `502`, `503`) → usually worth retrying |

## 📖 Lesson 12.2 — `requests`

```bash
pip install requests
```

```python
import requests

resp = requests.get("https://api.github.com/repos/python/cpython", timeout=10)
print(resp.status_code)              # 200
print(resp.headers["content-type"])
data = resp.json()                   # parse JSON body → dict
print(data["stargazers_count"])

resp.raise_for_status()              # raise HTTPError for 4xx/5xx — use it!
```

Query params, headers, JSON body:

```python
import os

token = os.environ["GITHUB_TOKEN"]              # secrets from env vars!
headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"}

r = requests.get("https://api.github.com/user/repos",
                 headers=headers, params={"per_page": 50, "sort": "updated"}, timeout=10)

r = requests.post("https://api.example.com/deployments",
                  json={"app": "api", "version": "1.4.2"},   # auto-encodes JSON + header
                  headers=headers, timeout=10)
```

## 📖 Lesson 12.3 — Errors, timeouts & retries (production-grade)

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

session = requests.Session()                      # reuses connections — faster
retries = Retry(total=5, backoff_factor=0.5,
                status_forcelist=[429, 500, 502, 503, 504],
                allowed_methods=["GET", "PUT", "DELETE"])
session.mount("https://", HTTPAdapter(max_retries=retries))

try:
    r = session.get("https://api.example.com/health", timeout=(3, 10))  # (connect, read)
    r.raise_for_status()
except requests.exceptions.Timeout:
    print("API timed out")
except requests.exceptions.ConnectionError:
    print("Cannot reach API")
except requests.exceptions.HTTPError as e:
    print(f"HTTP error: {e.response.status_code}")
```

> ⚠️ **Always set a `timeout`.** Without it, `requests` can wait forever.

## 📖 Lesson 12.4 — Pagination

APIs return results in pages. Loop until there are no more:

```python
def get_all(url, headers):
    items = []
    while url:
        r = requests.get(url, headers=headers, timeout=10)
        r.raise_for_status()
        items.extend(r.json())
        url = r.links.get("next", {}).get("url")    # GitHub-style Link header
    return items
```

## 📖 Lesson 12.5 — `urllib` (no install needed)

Useful in minimal containers or locked-down servers:

```python
import json
import urllib.request

with urllib.request.urlopen("https://api.github.com", timeout=10) as resp:
    print(resp.status, json.load(resp)["current_user_url"])
```

## 📖 Lesson 12.6 — Build your own health endpoint

Every service you deploy should expose `/health`. Python's stdlib can do it:

```python
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Health(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = json.dumps({"status": "ok"}).encode()
            self.send_response(200)
        else:
            body = b'{"error": "not found"}'
            self.send_response(404)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body)

HTTPServer(("0.0.0.0", 8000), Health).serve_forever()
```

```bash
curl -i localhost:8000/health
```

(For real services you'd use **Flask** or **FastAPI**.)

## 📖 Lesson 12.7 — AWS with `boto3` (intro)

```bash
pip install boto3
aws configure            # or env vars AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_DEFAULT_REGION
```

```python
import boto3

ec2 = boto3.client("ec2", region_name="eu-west-1")
resp = ec2.describe_instances(Filters=[{"Name": "instance-state-name", "Values": ["running"]}])
for reservation in resp["Reservations"]:
    for inst in reservation["Instances"]:
        name = next((t["Value"] for t in inst.get("Tags", []) if t["Key"] == "Name"), "-")
        print(inst["InstanceId"], inst["InstanceType"], name)

s3 = boto3.client("s3")
for bucket in s3.list_buckets()["Buckets"]:
    print(bucket["Name"])
s3.upload_file("backup.tar.gz", "my-backup-bucket", "daily/backup.tar.gz")

# Paginators handle pagination for you
paginator = s3.get_paginator("list_objects_v2")
for page in paginator.paginate(Bucket="my-backup-bucket", Prefix="daily/"):
    for obj in page.get("Contents", []):
        print(obj["Key"], obj["Size"])
```

> 💸 **Cost & safety:** Use the AWS free tier, set a billing alarm, and never commit AWS keys.
> On servers, use **IAM roles** instead of keys.

## ⚠️ Common mistakes
- No timeout
- Ignoring status codes (not calling `raise_for_status()`)
- Hard-coding tokens in scripts / committing them to Git
- Retrying non-idempotent `POST`s blindly (could create duplicates)
- Hammering an API without respecting `429` rate limits

---

## 🧪 Labs

### Lab 1 ⭐ — GitHub repo stats
Ask for an `owner/repo` and print stars, forks, open issues, default branch and last push date
from `https://api.github.com/repos/{owner}/{repo}`. Handle 404 nicely.

### Lab 2 ⭐⭐ — URL health checker
Write `healthcheck.py URL [URL...] [--timeout 5]` that prints status code and response
time (ms) for each URL, marks anything not 2xx/3xx or failing as `DOWN`, and exits `1`
if any URL is down. (Perfect for a cron job or CI smoke test.)

### Lab 3 ⭐⭐ — Your own health endpoint
Build a server on port 8000 with `/health` (returns status + uptime seconds) and
`/metrics` (returns CPU load average and disk usage % as JSON, use `os.getloadavg()`
and `shutil.disk_usage`). Then check it with your Lab 2 checker!

### Lab 4 ⭐⭐⭐ — AWS inventory (optional, needs an AWS account)
Use `boto3` to list all running EC2 instances in a region with their Name tag, type,
and launch time, and export to CSV. Bonus: list S3 buckets with their size.

---

## ✅ Checkpoint
- [ ] I know what 2xx/4xx/5xx mean and which errors are worth retrying
- [ ] Every request I make has a timeout and checks the status code
- [ ] I keep tokens in environment variables, never in code

👉 Next: [Module 13 — Testing & Code Quality](../13-testing-and-quality/README.md)
