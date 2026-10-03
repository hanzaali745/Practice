# Tabletop drills — model answers

There are other good answers. What matters: **mitigate first** (users OK again), then find the cause; check before you
change; say what you expect to see before you run a command.

---

### Drill 1 — CrashLoopBackOff after a deploy
1. **Mitigate:** it started with a deploy → roll back first, investigate second:
   `helm rollback demo-app -n prod` (or `kubectl rollout undo deployment/demo-app -n prod`). Users are fine again.
2. **Why it crashed:** `kubectl logs deploy/demo-app -n prod --previous` (the *previous*, crashed container),
   `kubectl describe pod <pod>` → `Last State: Terminated, Reason: Error / OOMKilled, Exit Code`.
   - Exit 1 + stack trace → config/env (missing Secret key, bad value — like the `8O00` port).
   - `OOMKilled` → memory limit too low for the new version.
   - Exit 0 repeatedly → the process ends (wrong command/entrypoint).
   - Liveness probe failures in Events → probe path/port changed or start-up got slower (add a `startupProbe`).
3. **Prevent:** the pipeline should catch it — `helm upgrade --atomic --wait` rolls back automatically; staging
   first; readiness gates so a broken version never receives traffic.

### Drill 2 — Pods stuck in Pending
1. `kubectl describe pod <pending-pod>` → **Events** tell you why: `0/3 nodes are available: 3 Insufficient cpu`
   (or memory, or a node selector/taint/affinity that nothing matches, or an unbound PVC).
2. Insufficient resources → is the cluster autoscaler running and allowed to add nodes (max size, quotas, instance
   availability)? `kubectl get nodes`, autoscaler logs. Short-term: add nodes manually / raise the node group max.
3. Check requests: are they realistic? Requests far above real use (`kubectl top pods`) waste capacity.
   A `ResourceQuota` in the namespace can also block (`kubectl describe quota -n prod`).
4. **Prevent:** capacity headroom for known peaks (sales!), priority classes so critical Pods win, alerts on Pending
   Pods (`kube_pod_status_phase{phase="Pending"} > 0` for 5m).

### Drill 3 — The Service answers nothing
1. `kubectl get endpointslices -l kubernetes.io/service-name=demo-app -n prod` (or `kubectl get endpoints demo-app`)
   → **empty**: the Service's selector matches no Pods.
2. `kubectl get svc demo-app -o jsonpath='{.spec.selector}'` vs `kubectl get pods --show-labels` → the label cleanup
   renamed `app: demo-app` to `app.kubernetes.io/name: demo-app` on the Pods but not in the Service (or vice versa).
3. **Fix:** make selector and labels match (in Git — GitOps will revert a hand edit). Also check `targetPort` matches
   the container port, and NetworkPolicies if endpoints exist but connections still fail.
4. **Prevent:** render and test manifests in CI (kubeconform + a test that every Service selects ≥1 Pod in kind).

### Drill 4 — Every pipeline is red on docker push
1. Nobody changed the workflow → something around it changed. Read the full log: which registry, which credential?
2. Likely causes: an expired/rotated token or secret (PATs expire!), the org changed `GITHUB_TOKEN` default
   permissions to read-only (`packages: write` now needed explicitly), a registry permission change, or rate limits.
3. Test: rerun with debug logging (`ACTIONS_STEP_DEBUG`), check the token's expiry/scopes, check org settings audit log.
4. **Fix:** give the job explicit `permissions: packages: write`; replace long-lived tokens with `GITHUB_TOKEN` or OIDC.
   **Prevent:** expiry alerts for any remaining tokens; explicit `permissions:` in every workflow (Phase 8 Module 05).

### Drill 5 — Terraform state lock
1. **Don't force-unlock yet.** First prove nothing is running: is the cancelled job's runner really gone? Any other
   pipeline or person applying? (`terraform force-unlock` while an apply is running = two writers = corrupted state.)
2. Read the lock info from the error (who, when, operation, ID). Check CI history.
3. Then `terraform force-unlock <LOCK_ID>`, run `terraform plan` and read it carefully: a cancelled *apply* may have
   left resources half-created; the plan shows what Terraform now thinks.
4. **Prevent:** don't cancel applies mid-way; one pipeline concurrency group per state; versioned state bucket
   (so a bad state can be restored).

### Drill 6 — ECS tasks can't pull images
1. Running tasks are fine, new ones can't reach ECR → the network path **from private subnets to ECR** broke.
   "Cleaned up unused resources in the VPC" → suspect: the NAT gateway, or VPC endpoints (ecr.api, ecr.dkr, S3
   gateway), or route table entries.
2. Check: the private subnets' route table (`0.0.0.0/0 → nat-...` still there and the NAT `available`?), endpoints
   and their security groups (443 from the tasks), CloudTrail for `DeleteNatGateway` / `DeleteVpcEndpoints` / `DeleteRoute`.
3. **Mitigate:** restore the NAT/endpoint/route (with Terraform if it's managed: `terraform plan` shows the drift).
4. **Prevent:** everything in Terraform, no console "cleanups"; drift detection; an alarm on ECS deployment failures.

### Drill 7 — The alert storm
1. **Find the common cause, not 200 causes.** All `TargetDown` in one AZ → that AZ (or the network to it) is the
   problem; latency and disk alerts may be consequences. Check the cloud provider's status/health dashboard.
2. Declare an incident, one person leads (incident commander), others take parts. Silence the duplicates in
   Alertmanager **with a comment and an expiry** so the signal isn't lost.
3. Mitigate: shift traffic away from the AZ (load balancers usually do it; check), scale up in healthy AZs.
4. Afterwards: inhibition rules (an "AZ down" alert suppresses per-target alerts), alerts on symptoms not causes,
   grouping by AZ.

### Drill 8 — RDS storage running out
1. **Buy time now:** increase allocated storage (`aws rds modify-db-instance --allocated-storage ... --apply-immediately`;
   storage scaling is online) — or enable storage autoscaling with a max.
2. **Find the cause:** what grows? Table sizes, a runaway job writing rows, transaction logs (a stuck replication
   slot or long-running transaction in PostgreSQL keeps WAL), temp files from a bad query.
3. Fix the cause (stop the job, drop the slot, archive old data). Note: you can't shrink RDS storage later.
4. **Prevent:** alert at 20% free with a forecast (predict_linear in Phase 9, or a CloudWatch anomaly alarm), storage
   autoscaling, retention/archiving policies.

### Drill 9 — A key in a public repo
1. **Rotate immediately** — deactivate the key in IAM, create a new one, update whatever used it. This is minute 1,
   not after the cleanup. Bots exploit public keys within minutes.
2. Check CloudTrail for what the key did since the commit (new users, instances, regions you don't use — crypto mining).
   Contain anything suspicious.
3. Then clean history (Module 03, Lab 7) and add prevention (gitleaks pre-commit, push protection).
4. Ask why a long-lived key existed at all → replace with roles/OIDC/SSO.

### Drill 10 — "It's slow", no alert
1. Make it concrete: which pages, all users or some (region? logged-in?), since when exactly? Get one example request.
2. Look at the latency **distribution**, not the average: p95/p99 by endpoint (Phase 9). Averages hide slow tails.
3. Follow one slow request: load balancer timing → app logs (ELK, `event.duration`) → its dependencies (DB slow queries,
   cache hit rate, external APIs). What changed at lunch? (deploys, config, traffic, a batch job, a noisy neighbour.)
4. Fix the cause; then fix the **detection gap**: an SLO-based latency alert on p99, so next time you know before
   support does.
