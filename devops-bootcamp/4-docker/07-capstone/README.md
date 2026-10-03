# Docker Module 07 — Docker Capstone 🏆

> **CEO note:** Put each project in your GitHub with a README, and make every image build in CI.
> These prove you can take an app from source code to a safe, repeatable container deployment.

**Definition of Done:**
- [ ] Multi-stage or slim images, non-root numeric user, `HEALTHCHECK`, OCI labels, `.dockerignore`
- [ ] Images tagged with the **git commit SHA** (never deploy `latest`)
- [ ] Compose file with healthchecks, `depends_on: condition: service_healthy`, named volumes, no unnecessary published ports
- [ ] Secrets via environment/`.env` (never baked into images), `.env` in `.gitignore`
- [ ] A smoke test that fails loudly, and a documented rollback

---

## Project 1 ⭐⭐⭐ — `shipit`: build → push → deploy → verify → auto-rollback (full reference solution)

A deploy tool for the demo-app stack, using a **private registry** you run yourself:

```bash
./shipit.sh registry            # start the private registry on localhost:5000
./shipit.sh release             # build demo-app tagged with the git SHA, push it to the registry
./shipit.sh deploy <tag>        # deploy that tag with Compose, wait for healthy, smoke test
                                #   → on failure: automatically redeploy the previous good tag
./shipit.sh status              # what's running + current/previous tags
./shipit.sh rollback            # manually go back to the previous good tag
./shipit.sh down                # stop the stack (volumes kept)
```

👉 Reference: [`solutions/shipit/`](solutions/shipit/). Run `./demo.sh` there to watch a good release,
a broken release being **rolled back automatically**, and the visit count surviving everything.

**Stretch goals:** push to `ghcr.io` from GitHub Actions instead of a local registry · add Trivy to
the release step and refuse to deploy images with CRITICAL findings · keep the last 5 tags only.

---

## Project 2 ⭐⭐ — Containerise your Python capstone
Take `healthmon` (Python Module 15) or your own capstone: multi-stage build with a venv, non-root, a
`HEALTHCHECK`, config via environment variables, and a `compose.yaml` that runs it on a schedule
alongside the services it monitors.

## Project 3 ⭐⭐⭐ — A classic three-tier stack
nginx (static frontend + reverse proxy `/api`) → a Python API → PostgreSQL (`postgres:16-alpine`) with
a named volume, healthchecks on every service, a nightly `pg_dump` backup container writing to a backup
volume, and a `restore.sh`. Prove the restore works by deleting the database volume.

## Project 4 ⭐⭐⭐ — Observability stack
Compose file with demo-app, **Prometheus** (scraping a metrics endpoint you add to demo-app) and
**Grafana** with a provisioned dashboard showing request rate. This is the start of real monitoring.

---

## 🎓 Docker phase complete!
Tick the [Docker expert checklist](../README.md#-docker-expert-checklist), then move on.

👉 Next phase: [Phase 5 — Kubernetes](../../5-kubernetes/README.md)
