# Tabletop drills — incidents you talk through

Some incidents are too big or too cloud-shaped to break on your laptop. Teams practise them as **tabletop exercises**:
read the page, then answer out loud (or write down) — *what do you check first, with which command, what would you
expect to see, what's your mitigation, what's the real fix?* Time yourself: 10 minutes per drill.
Model answers: [`solutions/tabletop-answers.md`](solutions/tabletop-answers.md) — only after you've answered.

---

### Drill 1 — Kubernetes: CrashLoopBackOff after a deploy
> 📟 `demo-app` in namespace `prod`: 0/3 Pods ready, status `CrashLoopBackOff`, since the 10:02 Helm upgrade.

### Drill 2 — Kubernetes: Pods stuck in Pending
> 📟 The HPA scaled `demo-app` from 3 to 8 replicas during a sale. 5 new Pods have been `Pending` for 10 minutes.

### Drill 3 — Kubernetes: the Service answers nothing
> 📟 After a "label cleanup" PR, `curl http://demo-app.prod.svc` from another Pod hangs / is refused. All Pods are `Running` and `Ready`.

### Drill 4 — CI: every pipeline is red
> 📟 Since this morning every PR fails in the `build` job with `denied: requested access to the resource is denied`
> on `docker push`. Nobody changed the workflow.

### Drill 5 — Terraform: the apply that won't run
> 📟 The infrastructure pipeline fails: `Error acquiring the state lock`. The lock was created 3 hours ago by a job that
> was cancelled. A colleague suggests `terraform force-unlock` right away.

### Drill 6 — AWS: new tasks can't start
> 📟 ECS service `demo-app`: deployments stuck, new tasks stop with `CannotPullContainerError ... i/o timeout`.
> Running tasks are fine. Yesterday the networking team "cleaned up unused resources" in the VPC.

### Drill 7 — Monitoring: the alert storm
> 📟 200 alerts in 5 minutes: `TargetDown` for every exporter in one availability zone, `HighLatency` on 6 services,
> `DiskWillFillIn4Hours` on 2 database hosts. Your phone keeps buzzing.

### Drill 8 — Database: the disk is almost full
> 📟 RDS `orders-db`: `FreeStorageSpace` below 5%, dropping ~1% per hour. Writes will fail in about 4 hours.

### Drill 9 — Security: a key in a public repo
> 📟 GitHub secret scanning alert: an AWS access key in a public repository's commit from 20 minutes ago.

### Drill 10 — "It's slow"
> 📟 Customer support: "the site has been slow since lunch". No alert fired. Dashboards look "normal-ish".
