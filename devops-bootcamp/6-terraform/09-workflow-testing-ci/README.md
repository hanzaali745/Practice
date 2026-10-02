# Terraform Module 09 — Workflow, Testing & CI 🔴

## 🎯 Objectives
- Run the quality checks every Terraform change needs: `fmt`, `validate`, **tflint**, security scanning
- Write automated tests with **`terraform test`** (including mocked providers)
- Use `check` blocks for continuous assertions
- Build a pull-request workflow: **plan on PR, apply after merge**, with approvals for prod
- Organise environments and promote changes safely

## 🧠 Why DevOps engineers care
A Terraform mistake can delete a production database. Teams protect themselves with automation: every pull
request is formatted, linted, scanned, tested and planned, a human reviews the plan, and only then does a
pipeline apply it. Building and maintaining that pipeline is a core DevOps responsibility.

---

## 📖 Lesson 9.1 — The fast checks (run them before every commit)

```bash
terraform fmt -recursive -check      # formatting (CI fails if anything is unformatted)
terraform validate                   # syntax, types, references
tflint --recursive                   # lint: unused variables, deprecated syntax, provider-specific bugs
trivy config .                       # security misconfigurations (open security groups, unencrypted buckets...)
```
**tflint** catches things `validate` doesn't — e.g. declared-but-unused variables, missing version constraints,
and (with the AWS plugin) invalid instance types. Configure it with `.tflint.hcl`:
```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
# plugin "aws" { enabled = true  version = "0.38.0"  source = "github.com/terraform-linters/tflint-ruleset-aws" }
```
Run all of it automatically on `git commit` with **pre-commit** (`pre-commit-terraform` hooks).

## 📖 Lesson 9.2 — `terraform test`

Tests live in `tests/*.tftest.hcl` next to a module. Each `run` block runs `plan` or `apply` and checks
`assert` conditions:

```hcl
# tests/webapp.tftest.hcl
variables {                      # defaults for all runs
  name        = "shop"
  environment = "dev"
  out_dir     = "./test-out"
}

run "one_replica_by_default" {
  command = plan                 # fast: nothing is created
  assert {
    condition     = output.ports == [8000]
    error_message = "default should be one instance on port 8000"
  }
}

run "prod_ports_are_consecutive" {
  command = plan
  variables {
    environment = "prod"
    port        = 9000
    replicas    = 3
  }
  assert {
    condition     = output.ports == [9000, 9001, 9002]
    error_message = "expected 3 consecutive ports"
  }
}

run "rejects_bad_names" {
  command = plan
  variables {
    name = "Bad_Name"
  }
  expect_failures = [var.name]    # the validation MUST fail — tests your guard rails
}

run "files_are_created" {
  command = apply                # really creates (and afterwards destroys) the resources
  assert {
    condition     = fileexists("${output.app_dir}/app.conf")
    error_message = "app.conf was not written"
  }
}
```
```bash
cd modules/webapp
terraform init
terraform test             # runs every run block, destroys what it applied
```

**Mock providers** let you test cloud modules without credentials or cost:
```hcl
mock_provider "aws" {}          # every aws_* resource gets fake computed values
run "bucket_is_private" {
  command = apply               # "applies" against the mock — instant, free
  assert {
    condition     = aws_s3_bucket_public_access_block.state.block_public_acls
    error_message = "the state bucket must block public ACLs"
  }
}
```

## 📖 Lesson 9.3 — `check` blocks: continuous assertions

```hcl
check "site_is_up" {
  data "http" "home" {
    url = "https://${aws_instance.web.public_dns}/"
  }
  assert {
    condition     = data.http.home.status_code == 200
    error_message = "the website is not returning 200"
  }
}
```
Checks run on every `plan`/`apply` and **warn** (they don't block). Good for post-deploy health checks and
catching drift in scheduled CI runs.

## 📖 Lesson 9.4 — The pull-request pipeline

```
 feature branch ─► pull request ─► CI: fmt · validate · tflint · trivy · test · plan ─► plan posted on the PR
                                                                                        │ human review
 merge to main  ─► CI: plan again ─► [manual approval for prod] ─► apply ─► check/smoke test
```

GitHub Actions sketch ([`solutions/.github-example/terraform.yml`](solutions/.github-example/terraform.yml)):
```yaml
jobs:
  checks:                                   # every PR
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -recursive -check
      - run: terraform init -backend=false && terraform validate
      - run: terraform test
  plan:                                     # every PR, per environment
    needs: checks
    permissions: { id-token: write, contents: read, pull-requests: write }
    steps:
      - uses: aws-actions/configure-aws-credentials@v4     # OIDC: no stored AWS keys!
        with: { role-to-assume: arn:aws:iam::123456789012:role/terraform-plan, aws-region: eu-west-1 }
      - run: terraform init && terraform plan -out=tfplan
  apply:                                    # only on main, after approval
    if: github.ref == 'refs/heads/main'
    environment: production                 # GitHub "environment" with required reviewers
    steps:
      - run: terraform init && terraform apply -auto-approve tfplan
```
Key ideas: **plan files** (`-out=tfplan`) ensure you apply exactly what was reviewed; separate IAM roles for
plan (read-only) and apply (write); `-lock-timeout=5m` so concurrent runs wait instead of failing.
Tools like **Atlantis**, **HCP Terraform** and **Spacelift** package this workflow.

## 📖 Lesson 9.5 — Environments and promotion

```
modules/           ← versioned, tested building blocks
live/
├── dev/           ← root module, state key dev/...,  applied automatically on merge
├── staging/       ← root module, state key staging/...
└── prod/          ← root module, state key prod/..., applied after approval
```
Promote a change by bumping the module version (`?ref=v1.5.0`) in dev → staging → prod, one pull request each.
Never apply prod from a laptop.

---

## ⚠️ Common mistakes
- Applying without a saved plan → applying something different from what was reviewed
- Long-lived cloud keys in CI secrets instead of OIDC roles
- Tests that only cover the happy path (test your `validation` blocks with `expect_failures`!)
- Ignoring tflint/trivy warnings until "later"
- Everyone running `apply` locally against shared environments

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — run `./check.sh`.

### Lab 1 ⭐ — Quality gate script
Write `tf_checks.sh DIR` that runs `fmt -check`, `validate` (with `init -backend=false`) and `tflint` on a folder and
exits non-zero if any fail. Break formatting on purpose and see it fail.

### Lab 2 ⭐⭐ — Test the webapp module
Write `tests/webapp.tftest.hcl` for the Module 06 `webapp` module: default ports, prod ports, invalid name rejected,
invalid replicas rejected, and an `apply` run that checks the files exist. Run `terraform test`.

### Lab 3 ⭐⭐ — Mocked cloud test
Write a test for the Module 08 `state-bucket` config with `mock_provider "aws"` that proves the bucket blocks all
public access and has versioning enabled — no AWS account needed.

### Lab 4 ⭐⭐⭐ — Pipeline
Put a small Terraform project in your own GitHub repo with the workflow from
`solutions/.github-example/terraform.yml`. Open a pull request with a change and see the checks run. (For the plan/apply
jobs against AWS you need an OIDC role — follow the AWS guide "Use IAM roles to connect GitHub Actions to actions in AWS".)

---

## ✅ Checkpoint
- [ ] I run fmt, validate, tflint and a security scanner on every change
- [ ] I can write `terraform test` files with plan/apply runs, assertions and `expect_failures`
- [ ] I can test cloud modules with mock providers
- [ ] I can describe a PR pipeline: plan on PR, reviewed plan file, approved apply, OIDC credentials

👉 Next: [Module 10 — Terraform Capstone](../10-capstone/README.md)
