# Ansible Module 07 — Testing & Quality 🔴

## 🎯 Objectives
- Lint YAML and Ansible code with **yamllint** and **ansible-lint** (production profile)
- Build a layered test strategy: syntax → lint → dry run → idempotence → end-state checks
- Test a role in a throwaway container with **Molecule**
- Put it all into one **quality gate** script and a CI pipeline

## 🧠 Why DevOps engineers care
A bad playbook can break every server at once. Teams that run Ansible in production never apply untested code:
every pull request is linted, every role is converged in a disposable container, run twice to prove idempotence,
and checked for the end state. This is the same "shift left" idea you used for Terraform (`terraform test`) and
Docker (image scans).

---

## 📖 Lesson 7.1 — The test pyramid for Ansible

| Layer | Tool | Catches | Speed |
|-------|------|---------|-------|
| YAML | `yamllint` | indentation, `mode: 0644` octal traps, truthy values | ms |
| Syntax | `ansible-playbook --syntax-check` | broken structure, unknown keywords | s |
| Lint | `ansible-lint` | non-FQCN modules, unnamed tasks, `command` without `changed_when`, risky permissions | s |
| Dry run | `--check --diff` | what would change on real hosts | s–min |
| Converge + idempotence | Molecule / `idempotence.sh` | tasks that fail, tasks that always report `changed` | min |
| Verify | Molecule `verify.yml` | wrong end state (service down, wrong permissions) | min |

## 📖 Lesson 7.2 — yamllint and ansible-lint

```bash
yamllint -c .yamllint .
ansible-lint                     # reads .ansible-lint
ansible-lint -p                  # parseable one-line output
ansible-lint --list-rules
```
`.ansible-lint`:
```yaml
profile: production          # min → basic → moderate → safety → shared → production
offline: true
exclude_paths: [.ansible/]
```
Fix the code rather than skipping rules. When a rule really doesn't apply, say why **on that line**:
```yaml
      run_once: true  # noqa: run-once[task] -- we use the default "linear" strategy
```
Typical findings: `fqcn[action-core]` (use `ansible.builtin.copy`), `name[missing]`, `no-changed-when`,
`risky-file-permissions`, `var-naming[no-role-prefix]`, `yaml[octal-values]`.

## 📖 Lesson 7.3 — Molecule

Molecule creates a test container, applies your role, runs it again for idempotence, runs your checks, and
destroys everything:
```
molecule/demo_app/
├── molecule.yml     # driver (docker), platform image, test sequence
├── converge.yml     # a play that applies the role
└── verify.yml       # assertions about the end state
```
`molecule.yml` (key parts):
```yaml
driver:
  name: docker
platforms:
  - name: molecule-demo-app
    image: ansible-lab-node:24.04     # Ubuntu + systemd, from lab-fleet
    pre_build_image: true
    privileged: true
    cgroupns_mode: host
    volumes: ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
    command: /sbin/init
provisioner:
  name: ansible
  inventory:
    host_vars:
      molecule-demo-app:
        demo_app_ports: [8001, 8002]
```
`verify.yml` checks **behaviour**, not implementation:
```yaml
    - name: Every instance answers with the configured message
      ansible.builtin.uri:
        url: "http://127.0.0.1:{{ item }}/"
        return_content: true
      register: page
      failed_when: page.json.message != demo_app_message
      loop: "{{ demo_app_ports }}"
```
```bash
molecule test -s demo_app        # the whole sequence, then clean up
molecule converge -s demo_app    # while developing: apply, keep the container
molecule login -s demo_app       # look around inside
molecule verify -s demo_app
molecule destroy -s demo_app
```

## 📖 Lesson 7.4 — A quality gate and CI

[`solutions/quality.sh`](solutions/quality.sh) runs every layer and prints a ✅/❌ table:
```
yamllint                          ✅
ansible-lint (production)         ✅
syntax-check site.yml             ✅
vault files encrypted             ✅
dry run (--check --diff)          ✅
idempotence                       ✅
smoke test web1 + web2            ✅
molecule test -s demo_app         ✅
✅ quality gate passed
```
In CI ([`solutions/.github-example/ansible.yml`](solutions/.github-example/ansible.yml)): lint on every pull
request, Molecule per role, and deploy only from `main` behind a manual approval, with the vault password coming
from a CI secret.

---

## ⚠️ Common mistakes
- Testing only "it ran without errors" — check the **end state** in `verify.yml`
- Skipping lint rules globally instead of fixing code or adding a reasoned `# noqa`
- Molecule images without systemd → services can't start, and you blame your role
- Tests that need the real servers → slow, flaky, and they can't run on every pull request
- Running ansible-lint without `offline: true` in CI → it tries to download collections

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `./quality.sh --deploy --molecule` (fleet up; tools from
`requirements-devops.txt`).

### Lab 1 ⭐ — Lint everything
Add `.yamllint` and `.ansible-lint` (production profile) and lint your Module 02–06 work. Fix every finding.
Then break things on purpose (`mode: 0644`, `copy:` without FQCN, a `command` without `changed_when`) and read
what each tool says.

### Lab 2 ⭐⭐ — Molecule for `demo_app`
Write a Molecule scenario that converges the Module 05 `demo_app` role in a container from the lab-fleet image,
checks idempotence, and verifies: every instance is active, answers with the configured message, the env file is
`0640` and group `demoapp`, and the app does not run as root.

### Lab 3 ⭐⭐ — The quality gate
Write `quality.sh [PROJECT] [--deploy] [--molecule]` that runs every layer, keeps going after a failure, prints a
✅/❌ table and exits non-zero if anything failed. Prove it catches a broken copy of your project.

### Lab 4 ⭐⭐⭐ — CI
Write a GitHub Actions workflow: lint job on pull requests, Molecule job (matrix over roles) after lint, and a
commented-out deploy job that writes the vault password from a secret. Add a second Molecule scenario for the
`redis` role from Module 06 (hint: give it a test password in `host_vars`).

---

## ✅ Checkpoint
- [ ] My projects pass yamllint and ansible-lint on the production profile
- [ ] I can write a Molecule scenario with converge, idempotence and verify steps
- [ ] I check end state and behaviour, not just "no errors"
- [ ] I can describe the CI pipeline for an Ansible repo, including how secrets reach it

👉 Next: [Module 08 — Ansible Capstone](../08-capstone/README.md)
