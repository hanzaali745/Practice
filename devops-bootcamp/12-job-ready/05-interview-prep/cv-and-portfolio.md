# CV, portfolio and job search

## Your GitHub is your portfolio
Recruiters spend ~30 seconds; engineers who interview you will click through. Make those seconds count.

- [ ] A **profile README**: one line about you, your stack, and links to your 4–6 best projects
- [ ] **Pin** the capstones: CI/CD pipeline (Phase 8), observability platform (Phase 9), AWS deployment (Phase 11),
      plus one of Kubernetes/Terraform/Ansible
- [ ] Each pinned repo has a README with: what it does (1 paragraph), an **architecture diagram**, how to run it,
      what you'd do next, and a CI badge that's green
- [ ] Clean history and conventional commits (Module 03); no secrets (run gitleaks on your repos!), no `.terraform/`
- [ ] Optional but strong: a short blog post or write-up per project ("How I cut deploys from a day to 10 minutes"),
      and one sanitized postmortem from Module 04

## The CV (1–2 pages)
```
NAME — DevOps / Platform Engineer                                   City · email · github.com/you · linkedin

SUMMARY  2 lines: what you do and what you're great at.
         "DevOps engineer focused on CI/CD and AWS. Built end-to-end delivery for a containerised service:
          Terraform, GitHub Actions with OIDC, ECS Fargate, Prometheus SLO alerting."

SKILLS   Cloud: AWS (VPC, IAM, ECS, Lambda, RDS, CloudWatch) · IaC: Terraform, Ansible · Containers: Docker,
         Kubernetes, Helm · CI/CD: GitHub Actions, Argo CD · Observability: Prometheus, Grafana, ELK ·
         Languages: Python, Bash · Linux, networking, Git

PROJECTS (or EXPERIENCE) — 3–5 bullets each, ACTION + WHAT + RESULT, with numbers:
  • Built a GitHub Actions pipeline (test → scan → sign → GitOps deploy) for a Python service;
    deploy time 1 day → 8 minutes, zero stored cloud credentials (OIDC)
  • Wrote Terraform for a 2-AZ ECS Fargate platform with CloudWatch alarms and runbooks; tested with terraform test
  • Designed SLO burn-rate alerts that replaced 12 threshold alerts, covering every past outage with 2 pages

CERTIFICATIONS  AWS Certified Solutions Architect – Associate (2026) …
EXPERIENCE / EDUCATION  — previous roles: highlight anything operational, automated or customer-facing
```
- Tailor the summary and skills order to each job ad (the ATS keyword match matters).
- No skill bars or ratings; no photo unless local custom expects it; PDF; spell-checked.
- Every bullet should survive "tell me more about that" in an interview.

## Certifications worth having
| Cert | When |
|------|------|
| **AWS Solutions Architect – Associate** | the best single cert for most DevOps job ads |
| **CKA** (Certified Kubernetes Administrator) | if the roles you want are Kubernetes-heavy (hands-on exam) |
| **HashiCorp Terraform Associate** | quick, cheap, common in job ads |
| AWS DevOps Engineer – Professional | later, with experience |

## A 30-day job search plan
| Week | Do |
|------|----|
| 1 | Polish GitHub + CV + LinkedIn (headline: "DevOps Engineer · AWS · Kubernetes · Terraform"). Make a list of 30 target companies. |
| 2 | Apply to 10–15 roles that match ~60%+ of the ad (don't wait for 100%). Message 5 engineers at target companies — ask about their work, not for a job. |
| 3 | Daily: 1 system design (out loud), 1 coding exercise, 5 questions from the bank, 1 behavioral story. Keep applying. |
| 4 | Mock interviews (a friend, a community, or an AI interviewer — see below). After every real interview write down every question you got; fill the gaps. |

Track applications in a simple table: company, role, date, contact, stage, next step. Rejections are normal — count
applications and interviews, not offers, in the first month.

## A mock interview script
Ask a friend (or an AI assistant) to play the interviewer with this prompt, then switch to a new section every 15 min:
> You are interviewing me for a junior/mid DevOps engineer role. Ask one question at a time and wait for my answer.
> Section 1: Linux and networking troubleshooting (follow up on my answers). Section 2: a scenario — our service
> returns 502s after a deploy, walk me through it. Section 3: design a CI/CD pipeline for a containerised app on AWS.
> Section 4: a behavioral question. At the end, give me honest feedback: what was strong, what was vague, what to study.
