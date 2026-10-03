# Job-ready Module 04 — Incident Practice 🔴

## 🎯 Objectives
- Respond to an incident like a professional: severity, roles, mitigate first, communicate, then fix
- Solve **random, timed** incidents on the lab server — without being told what's broken
- Handle incidents with **two** simultaneous causes (where the first fix doesn't seem to work)
- Write a blameless postmortem with real action items
- Talk through Kubernetes, cloud, CI and Terraform incidents in tabletop drills

## 🧠 Why DevOps engineers care
Modules 01–02 taught you the tools, one known problem at a time. Real pages don't say "this is the DNS scenario". This
module trains the part interviews and on-call actually test: staying systematic under time pressure, telling people what's
happening, and turning every incident into a better system. A good postmortem is also the best interview story you can
have ("tell me about an incident you handled").

---

## 📖 Lesson 4.1 — The first five minutes of an incident

1. **Acknowledge** the page (so nobody else wonders whether someone's on it).
2. **Assess impact:** who is affected, how badly? That sets the severity.
   | Severity | Meaning | Response |
   |----------|---------|----------|
   | SEV1 | outage or data loss for many users | all hands, incident commander, status page, updates every 15–30 min |
   | SEV2 | degraded or one important feature broken | on-call + help as needed, updates every 30–60 min |
   | SEV3 | minor, workaround exists | normal working hours |
3. **Declare it** in the team channel — even if you're not sure yet. It's cheap to downgrade.
4. **What changed?** Deploys, config runs, infrastructure changes, traffic, dependencies. Most incidents follow a change.
5. **Mitigate before you understand:** roll back, fail over, scale up, turn the feature flag off. Root cause comes after
   users are OK again.

**Roles** in bigger incidents: the **incident commander** coordinates and decides (and doesn't type commands), a
**communications lead** writes updates, **responders** investigate. One person typing per system.

## 📖 Lesson 4.2 — Communicating

A status update every N minutes, even when nothing changed:
```
[SEV2] /visits failing on web-1 — 14:35 update
Impact: visit counter returns errors for all users since 13:50; rest of the site OK.
Status: Redis is reachable from other hosts; investigating the network path on web-1.
Next update: 15:05, or sooner if it changes.
```
What's broken for whom → what we know → what we're doing → when the next update comes. No guesses presented as facts.
Keep a timeline as you go (times + what you saw/did): it's 80% of the postmortem.

## 📖 Lesson 4.3 — Under pressure

- Keep a hypothesis log: "I think X because Y; I'll test it with Z". Stops you going in circles.
- Don't change two things at once; don't "try things" in production without a reason. A guessed fix can add a second
  problem (see the [example postmortem](solutions/example-postmortem.md)).
- If the first fix "doesn't work", don't assume it was wrong — there may be **two** causes. Re-test from the start.
- Ask for help early. Hand over with a written summary when you're tired.

## 📖 Lesson 4.4 — Blameless postmortems
Write one for every SEV1/SEV2 (and for your practice incidents): [`postmortem-template.md`](postmortem-template.md).
Blameless means you ask *what allowed this to happen?* — a missing test, alert, guard rail, runbook — never *who*.
Good action items are specific, owned and dated, and they **prevent**, **detect faster** or **respond better**. "Be more
careful" is not an action item. See [`solutions/example-postmortem.md`](solutions/example-postmortem.md).

---

## ⚠️ Common mistakes
- Debugging silently for 40 minutes while everyone else wonders what's happening
- Hunting for the root cause while users are still down and a rollback was available
- Restarting things "to see if it helps" — destroying evidence (logs, process state) on the way
- Stopping at the first cause when there were two
- Postmortems that blame a person, or that end with no action items (or 20 vague ones)

---

## 🧪 Labs
The lab server from Modules 01–02 (`../lab/`). From now on you don't choose the scenario — the pager does.

### Lab 1 ⭐⭐ — Five random pages
`./lab.sh incident` five times (on different days is best). For each: start a timeline, post a first status update (in a
text file) within 5 minutes, fix it, `./lab.sh check`. Target: under 20 minutes and ≤ 1 hint each.

### Lab 2 ⭐⭐⭐ — Two problems at once
`./lab.sh incident --hard` — one of three incidents with **two** causes. The checker shows each part.

### Lab 3 ⭐⭐ — Write it up
Write a postmortem for your hardest incident from Labs 1–2 using the template. Compare it with the
[example](solutions/example-postmortem.md): is your root cause a *why*, and are your action items specific?

### Lab 4 ⭐⭐ — Tabletop
Do the 10 [tabletop drills](tabletop.md), 10 minutes each, out loud. Then read the
[model answers](solutions/tabletop-answers.md) and note what you missed.

### Lab 5 ⭐⭐⭐ — Be the chaos
Pair with a friend (or future you): one person breaks the lab server by hand (`docker compose exec server bash` as
root — anything from Modules 01–02, or something new), the other gets only a one-line alert. Swap roles. The person who
broke it writes the `check` they'd use to verify the fix.

---

## ✅ Checkpoint
- [ ] I can run the first five minutes of an incident: impact, severity, declare, what changed, mitigate
- [ ] I write clear status updates and keep a timeline
- [ ] I've solved five random incidents in under 20 minutes each, and a two-cause one
- [ ] I've written a blameless postmortem with specific, owned action items
- [ ] I can talk through Kubernetes, cloud, CI and Terraform incidents

👉 Next: [Module 05 — Interview Prep](../05-interview-prep/README.md)
