# Runbook — demo-app

Every alert links here. Each section: **what it means → how to check → how to fix → when to escalate.**

## DemoAppDown
**Means:** Prometheus can't scrape one demo-app instance for 1 minute.
**Check:** `docker compose ps app` · `docker compose logs --tail 50 app` · Grafana *demo-app — RED* → *Instances up*.
**Fix:** a crashed container restarts on its own (`restart: unless-stopped` in production); if it keeps dying, roll back
to the previous image (`APP_VERSION=<previous> docker compose up -d app`).
**Escalate:** if more than half of the instances are down, or `SiteUnreachable` fires too.

## DemoAppMissing
**Means:** no demo-app targets at all — the service is gone, or service discovery broke.
**Check:** Prometheus → *Status → Service discovery*; `docker compose ps`. **Fix:** start the service; fix the SD config.

## DemoAppHighErrorRate
**Means:** more than 5% of requests return 5xx for 2 minutes.
**Check:** *RED* dashboard → *Requests / s by status code* and *p95 by path*: which path? `RedisDown` firing too?
Logs: `docker compose logs app | grep -E " 50[0-9] "` (Phase 10 makes this a Kibana search).
**Fix:** dependency down → see its runbook; started after a deploy → roll back first, investigate second.

## DemoAppHighLatency
**Means:** p95 latency above 500 ms for 5 minutes. **Check:** *p95 by path* (is it only `/work`?), CPU saturation on
the *Host — USE* dashboard. **Fix:** scale out (`docker compose up -d --scale app=5`), or roll back a slow release.

## DemoAppErrorBudgetFastBurn
**Means:** errors are spending the 30-day budget ~14× too fast (gone in ~2 days). **Page-worthy.** Treat as
DemoAppHighErrorRate; after the fix, write a short incident note: start, end, impact, cause, follow-ups.

## DemoAppErrorBudgetSlowBurn
**Means:** a smaller, steady error leak (budget gone in ~5 days). **Ticket, not a page.** Find the failing path in
working hours.

## RedisDown
**Means:** the Redis exporter can't reach Redis — `/visits` returns 503. **Check:** `docker compose ps redis`,
`docker compose logs redis`. **Fix:** `docker compose up -d redis`. Data is lost if it had no volume (it doesn't here).

## SiteUnreachable
**Means:** the external health check through nginx fails — users are affected **right now**.
**Check:** `curl -v localhost:8080/health`; is nginx up? are any app instances up? **Fix:** restart nginx or the app.
Always escalate if it lasts more than 5 minutes.

## SiteSlow
**Means:** the health check through nginx takes more than 1 s for 5 minutes. **Check:** nginx logs, app latency,
host saturation. **Fix:** scale out; check for a noisy neighbour on the host.
