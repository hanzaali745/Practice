# Ansible Module 05 — Roles & Collections 🔴

## 🎯 Objectives
- Split playbooks into reusable **roles** with the standard folder layout
- Use role **defaults** for every tunable and override them from `group_vars`
- Validate role inputs with **argument specs**
- Install and pin **collections** (`ansible.posix`, `community.general`) with `requirements.yml`
- Choose between `roles:`, `import_role` and `include_role`

## 🧠 Why DevOps engineers care
A 300-line `site.yml` is hard to review and impossible to reuse. Roles are Ansible's unit of reuse — like
Terraform modules or Python packages. Real teams have a `common` role on every server and one role per service,
and they pull community code (collections) from Ansible Galaxy with pinned versions.

---

## 📖 Lesson 5.1 — Role layout

```bash
ansible-galaxy role init roles/demo_app      # creates the skeleton
```
```
roles/demo_app/
├── defaults/main.yml       # default variables (LOWEST precedence → meant to be overridden)
├── vars/main.yml           # role constants (HIGH precedence → rarely used)
├── tasks/main.yml          # what the role does
├── handlers/main.yml       # handlers (notify them by name from tasks)
├── templates/*.j2          # template: src: looks here automatically
├── files/                  # copy: src: looks here automatically
└── meta/
    ├── main.yml            # author, platforms, dependencies
    └── argument_specs.yml  # input validation
```
Delete the folders you don't use. Name variables with the **role name as a prefix** (`demo_app_ports`, not
`ports`) so two roles never clash — ansible-lint checks this.

## 📖 Lesson 5.2 — Using roles

```yaml
- name: Web tier
  hosts: web
  become: true
  roles:
    - role: demo_app
      tags: [app]
    - role: nginx_proxy
      vars:
        nginx_proxy_upstream_ports: "{{ demo_app_ports }}"   # wire roles together with variables
```
Roles listed under `roles:` run **before** the play's `tasks:`. Inside tasks:

| | When it's resolved | Use it for |
|--|--------------------|-----------|
| `ansible.builtin.import_role` | when the playbook is parsed (static) | normal use; tags and `--list-tasks` see its tasks |
| `ansible.builtin.include_role` | when the task runs (dynamic) | loops, or `when:` that depends on earlier results |

```yaml
  tasks:
    - name: Only deploy the app where it's enabled
      ansible.builtin.include_role:
        name: demo_app
      when: app_enabled | default(true)
```
`meta/main.yml` can list `dependencies:` (roles that must run first) — keep them few; explicit `site.yml` is
easier to understand.

## 📖 Lesson 5.3 — Defaults vs group_vars

`roles/demo_app/defaults/main.yml`:
```yaml
demo_app_ports: [8001]
demo_app_message: "Hello from demo-app"
```
`group_vars/web.yml` (wins over role defaults):
```yaml
demo_app_ports: [8001, 8002]
demo_app_message: "Hello from the demo_app role"
```
Rule of thumb: **every** knob gets a sensible default in `defaults/`; environments and groups override in
`group_vars/`. Users of your role should never need to edit the role itself.

## 📖 Lesson 5.4 — Argument specs (validate inputs)

`roles/demo_app/meta/argument_specs.yml`:
```yaml
argument_specs:
  main:
    short_description: Deploy demo-app as systemd services
    options:
      demo_app_ports:
        type: list
        elements: int
        required: true
      demo_app_redis_password:
        type: str
        no_log: true
```
Ansible checks these **before** the role runs:
```bash
ansible-playbook site.yml -e '{"demo_app_ports": ["x"]}'
# TASK [demo_app : Validating arguments against arg spec 'main'] → fails with a clear message
```

## 📖 Lesson 5.5 — Collections

A **collection** is a package of modules, plugins and roles: `ansible.builtin` (always there), `ansible.posix`,
`community.general`, `community.docker`, `amazon.aws`, `kubernetes.core`... Use the **full name** (FQCN):
```yaml
- name: Authorize each admin's SSH key
  ansible.posix.authorized_key:
    user: alice
    key: "{{ lookup('ansible.builtin.file', 'files/alice.pub') }}"
```
Pin what you depend on in `requirements.yml`:
```yaml
collections:
  - name: ansible.posix
    version: ">=1.5.0,<2.0.0"
  - name: community.general
    version: ">=9.0.0,<10.0.0"
```
```bash
ansible-galaxy install -r requirements.yml       # into ~/.ansible/collections
ansible-galaxy collection list                   # what's installed, and which version
ansible-doc ansible.posix.authorized_key
```
The `ansible` pip package already includes the popular collections; `ansible-core` alone has only
`ansible.builtin`. In CI, install `ansible-core` + `requirements.yml` for fast, reproducible runs.

---

## ⚠️ Common mistakes
- Role variables without the role prefix → silent clashes between roles
- Putting tunables in `vars/` (high precedence) → nobody can override them from group_vars
- Unpinned collections → a new major version breaks your playbooks on Monday morning
- Short module names (`authorized_key:`) instead of FQCN → ambiguous and flagged by ansible-lint
- Copying a role into every project instead of sharing it (Git repo or Galaxy + `requirements.yml`)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `ansible-playbook site.yml`, then `curl localhost:8081`.

### Lab 1 ⭐ — Explore the skeleton
`ansible-galaxy role init roles/demo_app`. Open every folder and write one line on what each is for. Delete the
ones you don't need.

### Lab 2 ⭐⭐ — Turn Module 04 into roles
Move the Module 04 playbook into two roles: `demo_app` (user, code, env file, systemd unit, instances, health wait,
restart handler) and `nginx_proxy` (install, site template, reload handlers). All variables prefixed, all with
defaults. `site.yml` should be about 15 lines. Second run: `changed=0`.

### Lab 3 ⭐⭐ — A `common` role with a collection
Write `roles/common` for **every** host: common packages; admin users from a list; their SSH key with
`ansible.posix.authorized_key` (use the lab key `lab-fleet/.ssh/id_ed25519.pub`); a sudoers drop-in validated with
`visudo -cf %s`; an SSH hardening drop-in validated with `sshd -t -f %s` that notifies a reload. Prove it:
`ssh -i ../../lab-fleet/.ssh/id_ed25519 -p 2223 alice@127.0.0.1 sudo whoami` → `root`.

### Lab 4 ⭐⭐⭐ — Contracts and pins
Add `meta/argument_specs.yml` to all three roles and show a bad input failing fast. Add `requirements.yml` with
pinned collection ranges. Run only one role with `--tags app`, and preview the whole thing on a **fresh** fleet
(`../lab-fleet/fleet.sh reset`) with `--check --diff` — make it pass.

---

## ✅ Checkpoint
- [ ] I can create roles with the standard layout and prefixed, defaulted variables
- [ ] I know when to use `roles:`, `import_role` and `include_role`
- [ ] My roles validate their inputs with argument specs
- [ ] I install and pin collections with `requirements.yml` and use FQCNs

👉 Next: [Module 06 — Vault & Secrets](../06-vault-and-secrets/README.md)
