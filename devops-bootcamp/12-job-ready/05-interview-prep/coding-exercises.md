# Live-coding exercises

DevOps coding interviews are rarely algorithm puzzles. They're **practical scripts**: parse a log, call an API, check
some servers, handle errors. Interviewers watch *how* you work: clarify the input, start simple, handle bad data,
test as you go, talk out loud.

**Rules for practice:** 30 minutes each, Python (or Bash where it says so), no AI help, standard library only. Write
at least two tests. Then compare with [`solutions/coding/`](solutions/coding/) (`python3 -m pytest -q` there).

### 1 ⭐ — Top talkers (Python and Bash)
Given an nginx access log (file or stdin), print the 10 IPs with the most requests and the count of 2xx/3xx/4xx/5xx
responses. Don't crash on malformed lines — count them. Then do the IP part as a Bash one-liner.
→ `top_ips.py`, `top_ips.sh`

### 2 ⭐⭐ — Health checker
Given a list of URLs, check them **in parallel** with a timeout. Print status and latency per URL; exit 1 if any is
unhealthy (connection error, timeout, or status ≥ 400). Why threads and not processes here?
→ `url_checker.py`

### 3 ⭐⭐ — Retry decorator
Write `@retry(attempts, base, retry_on)`: exponential backoff with full jitter, retries only the given exceptions,
re-raises the last error. Make it testable without actually sleeping.
→ `retry.py`

### 4 ⭐⭐ — What fills the disk?
Print the N largest files under a path: stay on one file system, skip symlinks, survive unreadable/vanishing files,
human-readable sizes. Bonus: don't sort every file.
→ `largest_files.py`

### 5 ⭐⭐ — Unready Pods
Read `kubectl get pods -A -o json` from stdin. Print each Pod that is not Ready with the most useful reason
(CrashLoopBackOff, OOMKilled with exit code, Unschedulable...). Ignore completed Jobs. Exit 1 if any are unready.
→ `unready_pods.py`

### 6 ⭐⭐ — Config drift between environments
Compare two `KEY=VALUE` files (staging vs production): added, removed, changed keys. Mask values of keys that look
secret (PASSWORD, TOKEN, KEY...). Support comments, blank lines, `export` and quotes; give a clear error with the line
number for garbage.
→ `env_diff.py`

### Questions interviewers add afterwards
- How would this behave with a 50 GB log file? (Stream it — never `read()` it all.)
- What if 10,000 URLs? (Bounded worker pool, rate limit, async.)
- How would you deploy and schedule this? (Container + CronJob, or Lambda + EventBridge — Phase 11.)
- How do you know it's working in production? (Exit codes, logs, metrics — Phase 9.)
