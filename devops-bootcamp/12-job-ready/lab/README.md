# The troubleshooting lab

One Ubuntu 24.04 "server" (`web-1`, systemd · nginx :80 → demo-app :8000 → Redis) that `lab.sh` breaks on demand.
Used by Modules [01](../01-linux-troubleshooting/README.md), [02](../02-networking-troubleshooting/README.md) and
[04](../04-incident-practice/README.md) — start with Module 01's introduction.

| File | What |
|------|------|
| `lab.sh` | `list` · `break NAME` · `shell` · `hint` · `check` · `incident [--hard]` · `status` · `reset` · `down` |
| `server/` | the server image: Dockerfile, demo-app unit, nginx site, logrotate config |
| `compose.yaml` | the server (privileged for systemd/iptables — lab only) + Redis; a small 64 MB log disk |
| `scenarios/NAME/` | `story.txt` (the alert), `hints.md`, `break.sh`, `check.sh` — don't peek before you've solved it |
| `test_lab.sh` | proves every scenario: break → check fails → reference fix → check passes (~10 s each) |

Needs Docker; the image is about 320 MB. `./lab.sh down` when you're done.
