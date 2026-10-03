# Postmortem: <short title — what users experienced>

> **Blameless:** we describe what the *system* allowed, not who to blame. People acted reasonably with what they knew;
> the fix is to the system (tests, alerts, guard rails, docs), never "be more careful".

| | |
|---|---|
| **Date** | YYYY-MM-DD |
| **Duration** | HH:MM (detected → resolved) |
| **Severity** | SEV1 (outage) / SEV2 (degraded) / SEV3 (minor) |
| **Impact** | who was affected, how many, what they couldn't do (numbers if you have them) |
| **Detected by** | alert / customer / colleague — and how long after it started |
| **Author** | you |

## Summary
Two or three sentences a manager can read: what broke, why, how it was fixed.

## Timeline (UTC)
| Time | Event |
|------|-------|
| 14:05 | the change / trigger |
| 14:07 | alert fired / first report |
| 14:10 | on-call starts investigating |
| 14:18 | mitigated (users OK again) |
| 14:40 | root cause fixed |

## Root cause
What actually caused it, and **why it was possible** (ask "why?" until you reach something the team can change).

## Investigation
What you checked, in order — including the dead ends (they show what was misleading).

## Resolution
What fixed it: mitigation first, then the real fix.

## What went well / what went badly / where we got lucky
- ✅
- ❌
- 🍀

## Action items
| Action | Type | Owner | Due |
|--------|------|-------|-----|
| e.g. alert on certificate expiry 30 days ahead | detect | | |
| e.g. config changes go through a PR with `nginx -t` in CI | prevent | | |
| e.g. runbook: "502 from nginx" | respond | | |
