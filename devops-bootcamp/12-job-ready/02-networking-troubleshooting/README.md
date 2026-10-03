# Job-ready Module 02 — Networking Troubleshooting 🟡

## 🎯 Objectives
- Debug "can't connect" **layer by layer** — name, route, port, TLS, HTTP — and say which layer is broken
- Tell DNS problems from `/etc/hosts` problems, and a **timeout** from a **refused** connection
- Read what's listening with `ss`, test connections with `nc` and `curl -v`, and time each phase of a request
- Inspect certificates with `openssl` and issue a correct one (SAN, chain, expiry)
- Find and remove the one firewall rule that breaks things — without opening everything
- Fix reverse proxy (nginx) 502s and port conflicts

## 🧠 Why DevOps engineers care
Half of all outages are "it can't reach something". Kubernetes Services, AWS security groups, load balancers, service
meshes and VPNs are all networking with extra steps — and the same few commands find the problem in every one of them.
"What happens when you type a URL into a browser?" is a classic interview question; this module makes you good at it.

---

## 📖 Lesson 2.1 — Layer by layer

| # | Question | Command | Broken looks like |
|---|----------|---------|-------------------|
| 1 | Does the name resolve — **as programs see it**? | `getent hosts NAME` | no answer, or the wrong IP |
| 2 | Is there a route? | `ip route get IP` | "unreachable" |
| 3 | Is the port open? | `nc -vz -w 3 IP PORT` | **refused** (nothing listens) vs **timeout** (packets dropped) |
| 4 | Does TLS work? | `openssl s_client -connect IP:443 -servername NAME` | wrong name, expired, unknown CA |
| 5 | Does HTTP answer? | `curl -v http://NAME/` | 4xx/5xx, slow first byte |

Start at the bottom of the stack that's failing and work up — or bisect: if `curl` to the IP works but to the name
doesn't, it's name resolution. [`solutions/netcheck.sh`](solutions/netcheck.sh) runs all five and stops at the first
broken layer.

**Refused vs timeout** is the most useful single clue: *refused* = the host is reachable and actively said "nothing
here" (service down, wrong port, listening on 127.0.0.1 only); *timeout* = something silently dropped your packets
(firewall, security group, wrong IP, host down).

## 📖 Lesson 2.2 — Name resolution is more than DNS

```bash
cat /etc/nsswitch.conf | grep hosts     # hosts: files dns  → /etc/hosts FIRST, then DNS
getent hosts redis                      # exactly what applications get
dig redis                               # asks the DNS server ONLY (ignores /etc/hosts)
dig @8.8.8.8 example.com +short         # ask a specific server
dig example.com +trace                  # follow delegation from the root
cat /etc/resolv.conf                    # which DNS server, search domains, ndots
resolvectl status                       # on systemd-resolved hosts (127.0.0.53)
```
When `dig` and `getent` disagree, look at `/etc/hosts`. In containers, the resolver is the runtime's (Docker:
`127.0.0.11`; Kubernetes: the `kube-dns` Service IP with `search` domains like `default.svc.cluster.local`).
Remember TTLs and caches: a fixed DNS record can take minutes to reach everyone.

## 📖 Lesson 2.3 — Sockets and ports

```bash
ss -tlnp                       # TCP, listening, numeric, with process (needs root for other users' processes)
ss -tnp state established      # who is connected to whom
ss -s                          # totals: thousands of TIME-WAIT or CLOSE-WAIT is a clue
lsof -i :8000                  # what holds port 8000
```
`0.0.0.0:8000` / `[::]:8000` = reachable from outside; `127.0.0.1:8000` = this machine only (common "works on the box,
not from outside" cause). Only one process can listen on an address+port: "Address already in use" means find the other
one first.

## 📖 Lesson 2.4 — HTTP with curl

```bash
curl -v http://localhost/health                                   # request and response headers, the conversation
curl -s -o /dev/null -w '%{http_code} dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} ttfb=%{time_starttransfer} total=%{time_total}\n' URL
curl --resolve demo.lab:443:127.0.0.1 https://demo.lab/          # test a name before DNS points at it
curl -H 'Host: demo.lab' http://127.0.0.1/                        # virtual hosts
```
Behind a reverse proxy: **502** = the proxy couldn't reach the upstream (down, wrong port); **504** = it reached it but
the answer took too long; **503** = often "no healthy upstream" (or the app saying it's unavailable). nginx's
`error.log` says which upstream address failed — always read it.

## 📖 Lesson 2.5 — TLS certificates

```bash
openssl s_client -connect host:443 -servername host < /dev/null      # handshake + chain
... | openssl x509 -noout -subject -issuer -ext subjectAltName -dates
openssl x509 -in cert.pem -noout -checkend 2592000 && echo "valid for 30+ days"
```
Clients check: the name is in the **Subject Alternative Name** list (not just CN), the dates are valid, and the
chain leads to a CA they trust (send the intermediate certificate too!). Monitor expiry (blackbox exporter's
`probe_ssl_earliest_cert_expiry` from Phase 9), and automate renewal (Let's Encrypt/ACME, cert-manager, ACM).

## 📖 Lesson 2.6 — Firewalls and packets

```bash
iptables -L -n -v --line-numbers      # rules WITH packet counters: the rule whose counter climbs is the one matching
iptables -S                           # rules as commands (easy to copy and delete exactly)
nft list ruleset                      # the modern backend
ufw status verbose                    # Ubuntu's friendly front end
tcpdump -ni any port 6379             # see the packets: SYNs with no reply = dropped somewhere
traceroute -T -p 443 host / mtr host  # where along the path it stops
```
In the cloud the same logic applies one level up: **security groups** (stateful, per instance), **NACLs** (stateless,
per subnet), route tables, and in Kubernetes **NetworkPolicies**. Remove the exact rule that hurts; never "flush
everything to test".

---

## ⚠️ Common mistakes
- "It's DNS" — or "it can't be DNS" — without running `getent` *and* `dig`
- Testing from the wrong place: from your laptop instead of from the machine that fails
- Treating timeout and refused as the same error
- Fixing a proxy 502 by restarting nginx when the upstream address is wrong
- Certificates for the wrong name, missing intermediates, or no expiry monitoring
- `iptables -F` (flush all) on a production box to "test" — and locking yourself out

---

## 🧪 Labs
Same lab server as Module 01 (`../lab/lab.sh`). Write notes per lab: which layer failed, the evidence, the fix.
Reference fixes: [`solutions/fixes/`](solutions/fixes/).

### Lab 1 ⭐ — Bad gateway
`./lab.sh break nginx-502`

### Lab 2 ⭐⭐ — Who's on my port?
`./lab.sh break port-conflict`

### Lab 3 ⭐⭐ — It's always DNS
`./lab.sh break dns`

### Lab 4 ⭐⭐ — It's not DNS
`./lab.sh break hosts-override`

### Lab 5 ⭐⭐ — Silent drops
`./lab.sh break firewall` — `check` makes sure you removed only the rule that hurts.

### Lab 6 ⭐⭐⭐ — The wrong certificate
`./lab.sh break tls` — issue a correct certificate from the lab CA.

### Lab 7 ⭐⭐⭐ — Your layer checker
Write `netcheck.sh HOST PORT [http|https] [PATH]`: resolution (getent vs dig), route, TCP (refused vs timeout), TLS
(SAN and dates), HTTP (status and timings). Copy it to the server (`docker compose cp netcheck.sh
server:/usr/local/bin/`) and run it during Labs 3–6: does it point at the right layer every time?

---

## ✅ Checkpoint
- [ ] I can debug a connection layer by layer and say which layer is broken
- [ ] I know the difference between DNS and name resolution, and between refused and timeout
- [ ] I can read `ss`, `curl -v` timings and nginx's error log
- [ ] I can inspect and issue a TLS certificate with the right SAN
- [ ] I can find the exact firewall rule that blocks traffic
- [ ] All six network scenarios pass `./lab.sh check`

👉 Next: [Module 03 — Git for Teams](../03-git-for-teams/README.md)
