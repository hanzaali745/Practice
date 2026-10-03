# Job-ready Module 05 — Interview Prep 🏆

## 🎯 Objectives
- Know what a DevOps interview loop looks like, and what each stage tests
- Answer the 75 most common technical questions clearly, with examples from your own work
- Run a 45-minute system design conversation with a structure
- Solve practical live-coding tasks calmly, with tests
- Tell strong STAR stories, built from your bootcamp projects and incidents
- Present yourself: GitHub portfolio, CV, certifications, and a 30-day search plan

## 🧠 Why this matters
Skills get you through the job; communication gets you the job. Many capable engineers fail interviews because they
answer in fragments, freeze on design questions or can't explain what they built. All of that is trainable — the same
way you trained `kubectl` and `terraform`: practise out loud, get feedback, repeat.

---

## 📖 Lesson 5.1 — The interview loop

| Stage | What they test | Prepare with |
|-------|----------------|--------------|
| Recruiter screen (30 min) | motivation, basics, salary, availability | your 90-second "about me", [CV](cv-and-portfolio.md) |
| Technical screen (45–60 min) | fundamentals: Linux, networking, Docker, K8s, cloud, CI/CD | [question bank](questions.md) |
| Troubleshooting (45 min) | method under pressure: "a server is slow / site returns 502" | Modules 01–02 and 04 of this phase |
| Live coding (45 min) | practical scripting in Python/Bash | [coding exercises](coding-exercises.md) |
| System design (45–60 min) | architecture, trade-offs, failure modes | [system design](system-design.md) |
| Behavioral (45 min) | ownership, collaboration, learning from failure | [story bank](behavioral.md) |
| Take-home (sometimes) | a small real task: Dockerise + pipeline + IaC | your Phase 8 and 11 capstones |

## 📖 Lesson 5.2 — How to answer technical questions
- **Clarify** before answering anything ambiguous ("Is this a VM or a container? Linux?").
- **Structure:** one-sentence answer → explanation → a real example from your work → a trade-off or a gotcha.
- **Think out loud** — interviewers grade the process. Silence looks like being stuck.
- **"I don't know"** is fine when followed by *how you'd find out*: "I haven't used X, but I'd expect it to work like Y;
  I'd check the docs for Z." Never bluff — follow-up questions expose it immediately.
- **Go one level deeper** than asked when you can (DNS → TTLs and caching; requests/limits → OOMKilled and throttling).
- Use the bootcamp: "In my AWS capstone I used OIDC instead of keys because…" beats any textbook definition.

## 📖 Lesson 5.3 — Troubleshooting interviews
You'll get a scenario ("users report 502s") and must drive the investigation by asking for command output. Use the
Module 01–02 method out loud: clarify impact and changes → mitigate if possible → outside in, layer by layer → one
hypothesis at a time → verify → prevent. Say what you **expect** to see before each command. Your lab incidents and
postmortems are perfect practice: retell them as interview answers.

## 📖 Lesson 5.4 — Take-home assignments
Typical: "Containerise this app, write a pipeline, deploy it with IaC, add monitoring — 4 hours." Win with: a README
explaining decisions and trade-offs, small commits, tests that run in CI, security basics (non-root image, no secrets,
least privilege), and a "what I'd do with more time" section. Timebox it — they're judging judgement, not hours.

---

## ⚠️ Common mistakes
- Memorised definitions with no example — or a long story with no structure
- Jumping into a design before asking a single requirement question
- Bluffing about a tool you haven't used
- "We did…" all the time — the interviewer needs to know what **you** did
- A GitHub full of half-finished tutorials and no README, while your best work is private
- Waiting until you feel "ready" to apply — you learn interviewing by interviewing

---

## 🧪 Labs

### Lab 1 ⭐ — The question bank, round 1
Answer all 75 [questions](questions.md) out loud (record yourself), 10–15 per day. Compare with the
[model answers](solutions/answers.md) and mark the weak ones.

### Lab 2 ⭐⭐ — Live coding
Do the 6 [coding exercises](coding-exercises.md), 30 minutes each, with tests. Then compare with
[`solutions/coding/`](solutions/coding/).

### Lab 3 ⭐⭐ — System design
Do the 5 [design prompts](system-design.md), 45 minutes each, drawing and talking. Compare with the
[worked answers](solutions/system-design-answers.md). Redo the weakest one a week later.

### Lab 4 ⭐⭐ — Your story bank
Fill every row of the [story bank](behavioral.md) with a STAR story. Say each one out loud in under 2 minutes.

### Lab 5 ⭐⭐ — Portfolio and CV
Work through the [portfolio checklist](cv-and-portfolio.md): profile README, pinned capstones with diagrams, a CV
with numbers. Ask someone in the industry to give you 10 minutes of feedback.

### Lab 6 ⭐⭐⭐ — Mock interviews
Three full mock interviews (60–90 min) using the [mock interview script](cv-and-portfolio.md#a-mock-interview-script):
one troubleshooting-heavy, one design-heavy, one behavioral. After each, write down 3 things to improve — and improve them.

### Lab 7 ⭐⭐ — The question bank, round 2
A week later, redo only the questions you marked weak in Lab 1. Repeat until none are left.

---

## ✅ Checkpoint
- [ ] I can answer the 🟢 questions in the bank confidently, with an example for each
- [ ] I can run a structured 45-minute system design discussion
- [ ] I've solved all six coding exercises with tests
- [ ] I have 8+ STAR stories and a 90-second "about me"
- [ ] My GitHub, CV and LinkedIn are ready, and I've done 3 mock interviews
- [ ] I've started applying 🚀

🎉 **This is the end of the bootcamp.** Tick the [Job-ready expert checklist](../README.md#-job-ready-expert-checklist),
then go back to the [bootcamp README](../../README.md) — and start applying.
