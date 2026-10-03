# System design for DevOps interviews

DevOps design questions are about **platforms and delivery**: how code gets to production, how it runs reliably, how
you know it's healthy. There's no single right answer — interviewers grade *how you think*.

## The framework (45 minutes)
1. **Clarify requirements (5 min).** Users, traffic, availability target, data, compliance, team size, budget,
   existing tools. Write the numbers down. Ask; don't assume.
2. **High-level design (10 min).** Draw the boxes and arrows: users → edge → compute → data, plus the delivery
   pipeline and observability. Say why each piece is there.
3. **Deep dive (15 min).** The interviewer picks an area — or you pick the riskiest one. Go concrete: tools, configs,
   numbers.
4. **Failure modes (10 min).** "What happens when X dies?" for each box. Single points of failure, blast radius,
   rollback, backups and restores, security.
5. **Trade-offs and next steps (5 min).** What you'd do first, what you deliberately left out, what you'd change at 10×.

Say trade-offs out loud ("Kubernetes gives us X, but for a team of 3 ECS is less to run"). Prefer boring, managed
technology unless there's a reason. Draw while you talk.

## Practice prompts
Do each on paper (or a whiteboard tool) in 45 minutes, talking out loud, before reading the
[worked answers](solutions/system-design-answers.md).

### Design 1 — A CI/CD platform for 20 microservices
> 20 services in separate repos, 4 teams, deploys to Kubernetes in staging and production. Today deploys are manual and
> take a day. Goal: any team can deploy safely many times a day.

### Design 2 — A highly available web application on AWS
> An online shop: 2,000 requests/s at peak, 99.95% availability target, a PostgreSQL database, images uploaded by
> users, traffic mostly from Europe. Budget matters.

### Design 3 — Observability for 50 services
> 50 services on Kubernetes, 3 clusters, on-call gets 300 alerts a week and still misses outages. Logs are scattered.
> Design monitoring, logging and alerting.

### Design 4 — Zero-downtime database migration
> Move the shop's database from a self-managed PostgreSQL on a VM to Amazon RDS, and later rename a heavily used
> column — without downtime.

### Design 5 — Infrastructure as code for a growing company
> 3 AWS accounts created by hand over 4 years, 5 engineers clicking in the console, frequent "who changed this?" moments.
> Get to infrastructure as code, safely, without stopping feature work.
