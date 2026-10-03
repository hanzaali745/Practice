# Model answers

Short versions of good answers — say them in your own words, and add **your own example** from the bootcamp
(the module in brackets) whenever you can: interviewers remember stories, not definitions.

## Linux & troubleshooting
1. **Slow server.** Clarify first (what's slow, for whom, since when, what changed). Then the first-60-seconds checks:
   `uptime` (load vs cores), `dmesg` (OOM, disk errors), `vmstat 1` (run queue, iowait, swapping), `top`, `free -h`,
   `df -h`/`df -i`, `iostat -xz 1`, `ss -s`, recent logs. Form a hypothesis, test it, change one thing. [12/01]
2. **Load average** = average number of processes running or waiting (CPU, and on Linux uninterruptible IO) over 1/5/15
   minutes. Compare with the core count: 8 on a 16-core box is fine; on 2 cores, work is queueing. Rising 1-min vs
   15-min shows a trend.
3. **df vs du.** Usually a **deleted file still held open** by a process — the name is gone (du can't see it) but the
   blocks aren't freed until it's closed. `lsof +L1`, then restart/stop the process (or truncate via `/proc/PID/fd/N`).
   Also: files hidden under a mount point, or reserved blocks. [12/01 deleted-file]
4. A **process** has its own memory space; **threads** share their process's memory. A **zombie** has exited but its
   parent hasn't read its exit status (`wait()`); it uses no resources but a PID — the fix is the parent (restart it).
5. `kill PID` sends **SIGTERM**: the process may clean up and exit (or ignore it). `kill -9` sends **SIGKILL**: the kernel
   stops it immediately — no clean-up, possible corrupted files. Always try TERM first.
6. `750` = owner rwx, group r-x, others nothing. On a **directory**, `x` means "may enter / access entries by name",
   `r` means "may list names". Without `x` on every parent directory you can't reach a file even if the file is 644.
7. An **inode** stores a file's metadata (owner, mode, blocks) — one per file. A file system has a fixed number
   (ext4) — millions of tiny files can exhaust inodes while space remains: `df -i`. [12/01 inodes]
8. `systemctl status svc` (state, exit code, last logs) → `journalctl -u svc -n 50` (the error) →
   `systemctl cat svc` (unit + drop-ins — was it changed?) → run the `ExecStart` command by hand as the service user →
   check permissions, ports (`ss -tlnp`), config syntax. After editing units: `daemon-reload`. [12/01 service-crash]
9. Linux uses spare RAM as **page cache** to speed up disk access, so "free" is low. **available** = free + cache
   that can be dropped — that's what matters. Worry when available is low and swap activity (`si/so`) appears.
10. When memory runs out, the kernel's **OOM killer** kills the process with the highest "badness" score to save the
    system. Evidence: `dmesg -T | grep -i "killed process"`, `journalctl -k`; in containers/Kubernetes,
    `OOMKilled` in `kubectl describe pod` (the cgroup limit, not the host, was hit).

## Networking
11. **URL to page:** browser cache → **DNS** resolution (resolver, recursion, TTL) → **TCP** handshake to the IP:443 →
    **TLS** handshake (certificate checked: name, dates, chain) → **HTTP** request (method, Host, headers) → often a CDN /
    load balancer → web server/reverse proxy → app → database/cache → response → browser renders, fetching more resources.
    Go deeper on whichever layer the interviewer asks about.
12. **TCP**: connection-oriented, reliable, ordered, flow/congestion control — HTTP, SSH, databases. **UDP**: no
    connection, no guarantees, low overhead — DNS queries, video/voice, metrics (StatsD), QUIC (HTTP/3 builds its own
    reliability on UDP).
13. **Refused**: the host answered with a RST — reachable, but nothing listens on that port (service down, wrong port,
    bound to 127.0.0.1). **Timeout**: no answer — packets dropped by a firewall/security group, wrong IP, or host down.
    [12/02]
14. Programs use the system resolver: `/etc/nsswitch.conf` order (usually `files dns`) → `/etc/hosts` → DNS servers in
    `/etc/resolv.conf` (often a local stub like systemd-resolved). `dig` talks to DNS directly and ignores `/etc/hosts`,
    so a hosts entry makes them disagree. Also caches and search domains. [12/02 hosts-override]
15. **L4** (TCP/UDP) balances connections by IP/port — fast, protocol-agnostic (AWS NLB). **L7** understands HTTP:
    routes by host/path/header, terminates TLS, adds headers, health-checks endpoints (AWS ALB, nginx, Ingress).
16. CIDR = an IP prefix + mask length. /24 = 256 addresses, /20 = 4,096 (2^(32−n)). AWS reserves 5 per subnet. [11/03]
17. TLS gives **confidentiality** (encryption), **integrity** and **authentication** of the server (and optionally the
    client — mTLS). The client checks the hostname is in the **SAN**, the validity dates, and that the chain leads to a
    trusted CA (intermediates sent by the server). [12/02 tls]
18. **TIME_WAIT**: the side that closed first waits ~60s so late packets don't confuse a new connection; thousands of
    them on a client making many short connections → use keep-alive/connection pooling. **CLOSE_WAIT**: the peer closed
    but *our* app never closed its socket — almost always an application bug (leaking connections).

## Git
19. **Merge** keeps true history with a merge commit — for integrating shared branches. **Rebase** rewrites your commits
    on top of the target for a linear history — for updating *your own* branch before review. Never rebase shared
    history. Many teams squash-merge PRs. [12/03]
20. On a shared branch: `git revert <sha>` (a new commit undoing it) and push — never reset + force-push `main`.
    For a merge commit: `git revert -m 1 <merge>`. If it's deployed, roll back the deployment first. [12/03]
21. `git bisect start BAD GOOD`, then mark commits good/bad — or `git bisect run ./test.sh` to automate. Binary search:
    ~5 steps for 30 commits, ~10 for 1,000. [12/03 bisect]
22. **Rotate the secret immediately** (revoke + replace), check logs for misuse, then purge it from history
    (`git filter-repo`, force-push branches and tags, re-clone), then prevent (pre-commit secret scanning, push
    protection, no long-lived keys). [12/03 leaked-secret]
23. **Trunk-based**: short-lived branches (≤ a day or two), small PRs, required CI and review, feature flags for
    unfinished work, `main` always deployable, automated deploys.

## Scripting
24. `-e` exit on an unhandled error, `-u` error on unset variables, `-o pipefail` a pipeline fails if any part fails.
    Gotchas: `-e` is ignored inside `if`/`&&`/`||` conditions and in functions called from them; `cmd | grep -q` can
    fail with SIGPIPE under pipefail; arithmetic `((x++))` returns 1 when x was 0. [3-bash/04]
25. Check before you act (`mkdir -p`, `id user || useradd`, "create if missing"), write files atomically (temp file +
    `mv`), use declarative tools (Ansible, Terraform) where possible, and make re-runs report "no change".
26. Quoted `"$@"` expands to each argument as a separate word (preserving spaces); `"$*"` joins them into one string.
    Unquoted, both word-split and glob — `"$@"` is almost always what you want. Always quote variables.
27. Python when there's real logic, data structures, JSON/YAML/APIs, error handling, tests, or more than ~100 lines.
    Bash for gluing commands, simple file/process work, and where Python isn't available (minimal containers).
28. Retry only **retryable** errors (timeouts, 429, 5xx — not 400/401), with **exponential backoff + jitter**, a max
    number of attempts and an overall deadline; make the operation idempotent; log each retry. (See the coding
    exercise `retry.py`.)

## Docker
29. A **VM** virtualises hardware and runs a full guest kernel (strong isolation, heavier, minutes to boot). A
    **container** is an isolated process on the host's kernel (namespaces + cgroups): lightweight, starts in
    milliseconds, weaker isolation.
30. Small base (slim/alpine/distroless), multi-stage builds (no compilers in the final image), fewer layers and a
    `.dockerignore`, pinned versions, non-root `USER`, no secrets in layers (use build secrets), read-only root FS,
    scan with Trivy, rebuild regularly for patches. [4-docker/06]
31. `ENTRYPOINT` is the executable that always runs; `CMD` provides default arguments (or the default command if no
    entrypoint). `docker run image ARGS` replaces `CMD`. Use the exec (JSON) form so signals reach the process.
32. Several `FROM` stages in one Dockerfile: build in a full image, `COPY --from=build` only the artefacts into a small
    runtime image → smaller, fewer vulnerabilities, no build tools in production.
33. `docker logs <c>`, `docker inspect <c>` (`State.ExitCode`, `OOMKilled`), run it interactively with a shell
    entrypoint (`docker run -it --entrypoint sh image`), check the command/entrypoint, env vars and mounts. Exit 0 =
    the main process simply finished (e.g. it daemonised itself).
34. **Namespaces** give the process its own view (PID, network, mount, UTS, IPC, user); **cgroups** limit CPU, memory,
    IO; plus capabilities, seccomp and a separate root filesystem (overlay layers). It's still a normal process on the
    host kernel.

## Kubernetes
35. **Pod**: one or more containers sharing network/storage, the smallest unit. **Deployment**: keeps N replicas of a
    Pod template, does rolling updates. **Service**: stable virtual IP/DNS name load-balancing to Pods selected by
    labels. **Ingress**: HTTP routing (host/path, TLS) from outside to Services, implemented by an ingress controller.
36. `kubectl describe pod` (events, last state, exit code, OOMKilled), `kubectl logs --previous`. Causes: app crash
    (config, missing secret), OOM, failing liveness probe, wrong command. If it followed a deploy, roll back first.
    [12/04 drill 1]
37. **Liveness** failing → the kubelet restarts the container (for deadlocks). **Readiness** failing → the Pod is removed
    from Service endpoints (no traffic) but not restarted. **Startup** → holds off the other probes while a slow app
    starts. Don't point liveness at dependencies (a DB outage would restart everything).
38. **Requests** are what the scheduler reserves (placement); **limits** are the maximum. Over the CPU limit → throttled;
    over the memory limit → OOMKilled. A node under memory pressure evicts Pods using more than they requested first.
39. A new ReplicaSet is scaled up while the old one scales down, governed by `maxSurge`/`maxUnavailable` and readiness.
    `kubectl rollout status`, `kubectl rollout undo deployment/x` (or `helm rollback`, or revert in Git with GitOps).
40. Both hold config; Secrets are for sensitive values and can be handled differently (RBAC, tmpfs mounts). By default
    Secrets are only **base64-encoded** in etcd — enable encryption at rest, restrict RBAC, or use an external secret
    store (External Secrets, Vault, Sealed Secrets).
41. kubectl sends the object to the **API server** (authn, authz, admission webhooks, validation) → stored in **etcd** →
    the Deployment **controller** creates a ReplicaSet → the ReplicaSet controller creates Pods → the **scheduler** picks a
    node for each → the node's **kubelet** asks the container runtime to pull and start containers → kube-proxy/CNI
    make the Pod reachable via Services once it's ready.
42. Workload identity: **EKS Pod Identity** or **IRSA** (a ServiceAccount annotated with an IAM role; the Pod gets
    short-lived credentials via OIDC). Same idea as GitHub OIDC in Phase 8. [11/06]

## Terraform & IaC
43. State maps your configuration to real resource IDs and stores attributes, so Terraform can compute diffs. Keep it
    remote (S3 with locking, encrypted, versioned), never in Git (it can contain secrets), one state per environment/
    component. [6-terraform/04]
44. Stop and read **why**: the plan marks the attribute that "forces replacement". Options: change the code so it
    doesn't (some attributes are immutable), use `create_before_destroy`, `moved` blocks if it's a rename, or accept a
    planned replacement in a maintenance window. Never apply a surprise destroy on stateful resources (databases!).
45. **Drift** = real infrastructure differs from code (console changes). Detect with a scheduled `terraform plan
    -detailed-exitcode` (exit 2 = changes) that alerts; fix by reverting the manual change or importing it into code.
46. When a group of resources is repeated or forms one concept with a clear interface (a VPC, a service on ECS). Not for
    wrapping a single resource. Version shared modules; keep inputs small.
47. Separate state per environment — separate root modules (`live/dev`, `live/prod`) calling the same versioned
    modules with different variables, or separate workspaces/accounts. Promote changes dev → prod through the pipeline.
    [6-terraform/10]
48. **Terraform**: provisioning infrastructure through APIs (VPCs, clusters, DNS, IAM) with state and plans.
    **Ansible**: configuring what's inside servers (packages, files, services) and orchestrating procedures. Often
    used together: Terraform creates the VM, Ansible configures it. [7-ansible/08]
49. `moved { from = ..., to = ... }` blocks (or `terraform state mv`), `import` blocks to adopt existing resources,
    `removed` blocks to forget without destroying. Always check the plan shows no destroy.

## CI/CD
50. **CI**: every change is merged often and automatically built and tested. **Continuous delivery**: every change that
    passes is releasable — deploying to production is a button. **Continuous deployment**: it deploys automatically.
51. PR: lint, unit tests, build image, scan, integration tests → merge → build once, tag with commit SHA, sign, push →
    deploy to staging (by digest) → smoke/e2e tests → approval or automatic promotion of the **same digest** to
    production → post-deploy checks and automatic rollback; everything as code. [8-cicd/08]
52. Store them in the CI secret store or a vault, scope them to environments with approvals, prefer **OIDC** short-lived
    cloud credentials over stored keys, least-privilege tokens, never echo them, don't expose them to fork PRs,
    pin third-party actions by SHA. [8-cicd/05]
53. **Rolling**: replace instances gradually (cheap, mixed versions for a while). **Blue/green**: a full second
    environment, switch traffic at once, instant rollback (double cost). **Canary**: send a small % of traffic to the new
    version, watch metrics, increase gradually (best risk control, needs good monitoring).
54. Git is the source of truth for the desired state; an agent in the cluster (Argo CD, Flux) **pulls** and continuously
    reconciles the cluster to match. Deploy = merge a PR; rollback = revert; drift is corrected automatically. [8-cicd/07]
55. Pin dependencies and actions (by digest/SHA), minimal permissions, scan code/deps/images (SCA, Trivy), sign images
    and generate SBOMs and provenance (SLSA), verify signatures at deploy (admission policies), protect branches,
    require reviews, isolate builds. [8-cicd/04–05]

## Monitoring & logging
56. **Metrics**: numbers over time, cheap, for dashboards and alerts ("error rate is 5%"). **Logs**: detailed events,
    for investigating ("this request failed because..."). **Traces**: one request's path through many services with
    timings, for finding where latency comes from.
57. Alert on **symptoms users feel**: error rate, latency (p99), availability, saturation that will soon hurt (disk
    filling, certificate expiry) — ideally SLO burn rates. Don't page on causes that don't hurt users yet (one node's
    CPU at 90%) — dashboard those. Every alert needs an action and a runbook. [9-monitoring/06]
58. **SLI**: a measurement of service quality (% successful requests under 300 ms). **SLO**: the target (99.9% over 30
    days). **Error budget**: what's allowed to fail (0.1%) — when it's spent, slow down releases and invest in reliability.
59. **RED** for services: Rate, Errors, Duration. **USE** for resources: Utilisation, Saturation, Errors.
60. Every unique label combination is a separate time series in memory. Labels with unbounded values (user IDs, request
    IDs, full URLs) explode the series count → memory/CPU blow-up and slow queries. Keep labels bounded. [9-monitoring/02]
61. A shipper on every host (Filebeat/Fluent Bit) → optional processing (Logstash) → storage (Elasticsearch/Loki).
    Watch: structured JSON logs with a common schema, retention/ILM and cost, back-pressure and buffering, no secrets/PII
    in logs, time sync, access control. [10-elk]
62. Burn rate = how fast you're spending the error budget (1 = exactly on budget). Alerting on e.g. 14.4× over 1 h
    (and 5 min) catches fast budget burns quickly and ignores short blips; a slower window catches steady burns.
    Thresholds either page too often or too late. [9-monitoring/06]

## AWS & cloud
63. A VPC is your private network. **Public** subnets have a route to an Internet Gateway (load balancers, NAT).
    **Private** subnets don't — instances there reach the internet outbound through a **NAT gateway** in a public subnet
    (or reach AWS services through VPC endpoints), and can't be reached from the internet. [11/03]
64. A **user** has long-lived credentials (password/keys) for one person or app. A **role** is assumed for short-lived
    credentials by users, services (EC2, Lambda, ECS tasks) or external identities (OIDC). Roles: no keys to leak or
    rotate. [11/02]
65. **Security groups**: stateful, attached to ENIs/instances, allow rules only. **NACLs**: stateless (return traffic
    needs its own rule), per subnet, allow and deny, numbered rules. SGs are the main tool; NACLs a coarse extra layer.
66. Multiple AZs for everything: ALB across AZs → Auto Scaling group / ECS service spread across AZs with health checks →
    Multi-AZ RDS → stateless app servers (sessions in Redis/DynamoDB) → backups, alarms, infrastructure as code;
    multi-region only if the requirements justify the cost. [11/04, 11/08]
67. Classes trade storage price vs access price/latency: Standard, Intelligent-Tiering, Standard-IA, Glacier tiers.
    **Versioning** protects against overwrite/delete; **lifecycle rules** move/expire objects (and old versions)
    automatically. [11/05]
68. **Lambda**: event-driven, short (≤15 min) code, no servers, pay per call. **ECS (Fargate)**: containers with the
    least operations, AWS-native. **EKS**: when you need Kubernetes (ecosystem, portability, many teams) and can run it.
    [11/06]
69. Visibility first (Cost Explorer, tags, budgets and alerts), then: right-size, turn off non-prod at night, Savings
    Plans/RIs for steady load, Spot for interruptible work, S3 lifecycle, delete idle resources (EBS, IPs, NAT
    gateways, old snapshots), log retention. [11/01, 11/07]
70. AWS Organizations with separate accounts per environment/workload (prod, staging, dev, security/log-archive,
    shared services), SSO via IAM Identity Center, SCPs as guard rails, centralized CloudTrail/Config/GuardDuty,
    networking via Transit Gateway, account vending as code (Control Tower / Terraform).

## Incidents & culture
71. Use **STAR** (see [`behavioral.md`](../behavioral.md)) — a real incident if you have one, or your best lab
    incident with its postmortem. Show: how you assessed impact, mitigated first, communicated, found the root cause
    (and the second one!), and what changed afterwards.
72. A postmortem that asks what in the *system* allowed the failure (process, tooling, missing checks) rather than who
    to blame, so people share the truth and the organisation learns. It ends with specific, owned action items. [12/04]
73. A culture and practice where the people who build software also run it, with shared ownership, automation
    (CI/CD, IaC), fast feedback (monitoring) and small, frequent, safe changes. Not a job title or a tool.
74. Understand their reasons, agree on the criteria (risk, cost, time), use data or a quick experiment, write it down
    (an ADR), decide — and commit fully once decided ("disagree and commit").
75. Impact and urgency: user-facing outages and security first, then things that block others, then the rest. Make the
    trade-off visible to your manager instead of silently juggling; say no (or "not now") with reasons.
