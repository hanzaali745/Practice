# Postmortem: /visits failed for 70 minutes (cache unreachable)

| | |
|---|---|
| **Date** | 2026-03-12 |
| **Duration** | 01:10 (13:50 → 15:00) |
| **Severity** | SEV2 — the visit counter failed; the rest of the site worked |
| **Impact** | every /visits request: 503 after a 2 s wait (~4,000 requests) |
| **Detected by** | the 5xx-ratio alert, 4 minutes after the first errors |
| **Author** | on-call engineer |

## Summary
A firewall "hardening" change dropped outgoing traffic to Redis (port 6379) on web-1. While investigating, the first
on-call suspected DNS and pinned `redis` in `/etc/hosts` to an IP from an outdated wiki page, which added a second fault.
Removing the hosts entry and exactly one firewall rule restored service.

## Timeline (UTC)
| Time | Event |
|------|-------|
| 13:45 | firewall change OPS-3110 applied by config management |
| 13:50 | first 503s on /visits |
| 13:54 | 5xx-ratio alert pages on-call #1 |
| 14:05 | on-call #1 restarts demo-app and Redis — no change |
| 14:15 | on-call #1 suspects DNS, adds `10.255.255.1 redis` to `/etc/hosts` (IP from the old wiki) — no change; hands over |
| 14:35 | on-call #2 (me) runs `netcheck.sh redis 6379`: name resolves to 10.255.255.1, TCP timeout |
| 14:41 | `dig redis` and `getent hosts redis` disagree → stale `/etc/hosts` line found and removed |
| 14:43 | still timing out: `iptables -L OUTPUT -v` shows DROP on 6379 with rising counters |
| 14:58 | rule removed after confirming with the change owner; /visits OK |
| 15:00 | resolved; 5xx ratio back to 0 |

## Root cause
1. OPS-3110 blocked a list of "legacy" ports, including 6379, which Redis still uses. The change wasn't tested against
   the flows the services on the box need.
2. During the incident, a change made without a confirmed hypothesis (the `/etc/hosts` pin) added a second fault and
   hid the first one: after it, the symptom was the same, so it looked like "nothing changed".

Why possible: firewall changes have no pre-deploy check of required flows; the wiki still listed a decommissioned
Redis IP; there was no runbook for "dependency unreachable", so the first responder guessed.

## Investigation
Restarts and a guessed fix (14:05–14:20) cost 30 minutes and made things worse. Testing layer by layer (name → route → TCP) found
both problems in 8 minutes. `dig` alone was misleading: it ignores `/etc/hosts`.

## Resolution
Removed the hosts entry; deleted exactly the 6379 rule (kept the rest of OPS-3110, confirmed with its owner).

## What went well / badly / lucky
- ✅ the alert fired within 4 minutes; the layer-by-layer check was fast
- ❌ the first 30 minutes were restarts without a hypothesis; no runbook for "dependency unreachable"
- 🍀 only one non-critical endpoint used Redis

## Action items
| Action | Type | Owner | Due |
|--------|------|-------|-----|
| Remove the decommissioned Redis IP from the wiki; manage `/etc/hosts` with Ansible and alert on drift | prevent | platform | +2 weeks |
| Firewall changes: list required flows per host, test them in CI before rollout | prevent | security | +1 month |
| Runbook "dependency unreachable" with `netcheck.sh` | respond | on-call | +1 week |
| Probe Redis from each app host (blackbox TCP) so the cause shows in the alert | detect | platform | +2 weeks |
