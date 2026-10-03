# AWS Module 02 — IAM: Identity & Access 🟢

## 🎯 Objectives
- Explain users, groups, roles, policies and how AWS decides "allow or deny"
- Read and write **policies** with actions, resources and **conditions** (MFA, region, tags)
- Use **roles** and **STS** for temporary credentials — for people, EC2, Lambda and CI (OIDC)
- Apply least privilege; find risky IAM setups automatically
- Test automation offline with **moto** (in-process mock and local server)

## 🧠 Why DevOps engineers care
Almost every AWS breach starts with IAM: a leaked key, a role that trusts too much, a `"*"` that was "temporary". You'll
write policies for apps, pipelines and people every week. Getting IAM right is the difference between a mistake that's
annoying and one that's a headline.

---

## 📖 Lesson 2.1 — The parts

| | What | Credentials |
|--|------|-------------|
| **User** | a person (or legacy app) | password and/or long-lived access keys — avoid keys |
| **Group** | a set of users; attach permissions here | — |
| **Role** | an identity that is **assumed** by people, services (EC2, Lambda) or other accounts / OIDC (CI) | temporary, from STS |
| **Policy** | a JSON document of permissions | — |

Prefer: people via **IAM Identity Center** (Module 01), workloads via **roles**, CI via **OIDC** (Phase 8). IAM users with
keys are the exception.

## 📖 Lesson 2.2 — Reading a policy

```json
{"Version": "2012-10-17",
 "Statement": [{
    "Sid": "ReadObjectsInIt",
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::bootcamp-reports/*",
    "Condition": {"Bool": {"aws:SecureTransport": "true"}}}]}
```
**Effect** + **Action** + **Resource** (an ARN: `arn:aws:service:region:account:resource`) + optional **Condition**.

How AWS decides:
```
explicit Deny anywhere? ──yes──► DENY
        │ no
an Allow that matches? ──no───► DENY (default)
        │ yes
        └──────────────────────► ALLOW
```
So a `Deny` always wins — that's how guard rails like [`deny-outside-region.json`](solutions/policies/deny-outside-region.json)
and [`require-mfa.json`](solutions/policies/require-mfa.json) work, whatever else someone is allowed.

## 📖 Lesson 2.3 — Conditions you'll use

| Condition key | Example |
|---------------|---------|
| `aws:MultiFactorAuthPresent` | sensitive actions only with MFA |
| `aws:RequestedRegion` | stay in one region |
| `aws:ResourceTag/owner` + `${aws:username}` | start/stop only *your* instances ([`ec2-own-instances.json`](solutions/policies/ec2-own-instances.json)) |
| `aws:SourceIp`, `aws:SourceVpce` | only from the office / a VPC endpoint |
| `aws:SecureTransport` | HTTPS only |
| `token.actions.githubusercontent.com:sub` | which repo/environment may assume a CI role (Phase 8) |

## 📖 Lesson 2.4 — Roles and STS

A role has two policies: the **trust policy** (*who may assume me*) and **permission policies** (*what I can do*):
```bash
aws iam create-role --role-name reports-reader --assume-role-policy-document file://trust.json
aws iam attach-role-policy --role-name reports-reader --policy-arn arn:aws:iam::123456789012:policy/s3-read-reports
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/reports-reader --role-session-name me
```
EC2 instances get a role through an **instance profile** ([`trust-ec2.json`](solutions/policies/trust-ec2.json)) — apps on
the instance get rotating credentials automatically, so **no keys on servers, ever**. Same for Lambda, ECS tasks and
pods on EKS (IRSA / Pod Identity).

## 📖 Lesson 2.5 — Least privilege in practice

1. Start from AWS managed policies (`ReadOnlyAccess`) to explore, then write narrow customer-managed policies.
2. Scope resources (`arn:aws:s3:::bootcamp-reports/*`, not `*`).
3. Use **IAM Access Analyzer**: validate policies (`aws accessanalyzer validate-policy`), find resources shared outside
   the account, and generate a policy from what a role actually used in CloudTrail.
4. Review regularly — [`iam_audit.py`](solutions/iam_audit.py) flags console users without MFA, old keys, admin
   policies, direct attachments and roles anyone can assume.

## 📖 Lesson 2.6 — Testing AWS automation without AWS

```python
from moto import mock_aws

@mock_aws                         # every boto3 call inside goes to an in-memory fake AWS
def test_audit_finds_admin_users():
    iam = boto3.client("iam")
    iam.create_user(UserName="bob")
    ...
```
[`test_iam_audit.py`](solutions/test_iam_audit.py) builds a bad account in memory and checks the audit finds every
problem. Unit tests like this run in CI on every pull request — no account, no cost, no risk.
(Note: moto doesn't **enforce** permissions by default — test *what your code does*, and test real permissions in a
sandbox account.)

---

## ⚠️ Common mistakes
- `"Action": "*", "Resource": "*"` because "it didn't work otherwise"
- Access keys for apps running on AWS (use roles), or keys in Git
- Trust policies with `"Principal": {"AWS": "*"}`
- Policies attached to individual users instead of groups/permission sets
- Forgetting that an explicit Deny beats every Allow when debugging "AccessDenied"

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Labs 1–3 run on local AWS (`source ../local-aws/env.sh`).

### Lab 1 ⭐ — Read policies
For each file in `solutions/policies/`, explain in one sentence what it allows or denies, and to whom. Which statement
in `require-mfa.json` lets a new user set up MFA without having MFA yet?

### Lab 2 ⭐⭐ — Users, groups, roles
Write `iam_lab.sh`: a customer-managed policy to read one bucket, a `developers` group with it, `alice` in the group, a
role with a trust policy for your account, and `assume-role` with a 15-minute session. Add `--cleanup`.

### Lab 3 ⭐⭐⭐ — Audit IAM
Write `iam_audit.py` and its moto tests. Make the tests create a deliberately bad account (admin user without MFA, a
role anyone can assume) and prove every finding appears.

### Lab 4 ⭐⭐ — ☁️ Guard rails
In your real account, attach `deny-outside-region.json` to a test user and try to list instances in another region.
Then use **IAM Access Analyzer → Policy validation** on all your policies.

---

## ✅ Checkpoint
- [ ] I can explain users, groups, roles, policies and the allow/deny evaluation
- [ ] I write narrow policies with conditions and know the important condition keys
- [ ] I use roles and temporary credentials instead of keys for workloads and CI
- [ ] I can audit IAM automatically and test AWS automation with moto

👉 Next: [Module 03 — Networking (VPC)](../03-networking-vpc/README.md)
