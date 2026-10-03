# Ansible Module 03 — Variables, Facts, Conditionals & Loops 🟡

## 🎯 Objectives
- Define variables in plays, `group_vars/`, `host_vars/` and on the command line — and know which wins
- Use **facts** about each host (OS, memory, IPs...)
- Save task results with `register` and act on them
- Run tasks conditionally with `when`, and repeat them with `loop`
- Handle failures with `block` / `rescue` / `always`

## 🧠 Why DevOps engineers care
The same playbook must configure web and database servers, dev and prod, Ubuntu 22.04 and 24.04 — differently.
Variables, facts, conditions and loops are what turn a fixed list of steps into reusable automation that adapts to
each host.

---

## 📖 Lesson 3.1 — Where variables live

```
playbook-folder/
├── site.yml
├── group_vars/
│   ├── all.yml         # every host
│   ├── web.yml         # hosts in group "web"
│   └── db.yml
└── host_vars/
    └── db1.yml         # just db1
```

`group_vars/all.yml`:
```yaml
timezone: Etc/UTC
common_packages: [curl, vim, htop, tree]
admin_users:
  - name: alice
    shell: /bin/bash
  - name: bob
    shell: /bin/bash
```
`group_vars/web.yml`:
```yaml
web_packages: [nginx]
site_title: "Bootcamp web tier"
```

Use them anywhere with Jinja2: `{{ site_title }}`, `{{ admin_users[0].name }}`, `{{ common_packages | join(', ') }}`.

**Precedence** (simplified — later wins):
`role defaults` < `group_vars/all` < `group_vars/<group>` < `host_vars/<host>` < play `vars:` < `set_fact`/`register` < `-e` extra vars (always win).

```bash
ansible-playbook site.yml -e "site_title='Hot fix'"       # override anything for one run
ansible-inventory --host web1 --vars                       # see what a host ends up with
```

## 📖 Lesson 3.2 — Facts

At the start of each play, Ansible gathers **facts** (the `Gathering Facts` task):
```yaml
- name: Show some facts
  ansible.builtin.debug:
    msg: >-
      {{ inventory_hostname }} runs {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
      with {{ ansible_facts['memtotal_mb'] }} MB RAM and {{ ansible_facts['processor_vcpus'] }} vCPUs
```
```bash
ansible web1 -m setup | less                                # every fact
ansible web1 -m setup -a "filter=ansible_default_ipv4"
```
Skip fact gathering for speed when you don't need it: `gather_facts: false`.

Magic variables: `inventory_hostname`, `group_names`, `groups['web']`, `hostvars['db1']['ansible_port']`.

## 📖 Lesson 3.3 — `register` and `when`

```yaml
- name: Is there a maintenance flag?
  ansible.builtin.stat:
    path: /etc/maintenance
  register: maint                        # save the module's result

- name: Restart only when not in maintenance
  ansible.builtin.service:
    name: nginx
    state: restarted
  when: not maint.stat.exists            # condition (plain Jinja2, no {{ }})

- name: Only on Ubuntu 24.04 web servers
  ansible.builtin.debug:
    msg: "modern web server"
  when:                                  # a list = all must be true (AND)
    - "'web' in group_names"
    - ansible_facts['distribution_version'] is version('24.04', '>=')
```
`debug: var=maint` shows everything a registered result contains.

**`changed_when` / `failed_when`** — control how a task reports:
```yaml
- name: Check the app version
  ansible.builtin.command: python3 --version
  register: pyver
  changed_when: false                    # read-only command: never "changed"
```

## 📖 Lesson 3.4 — Loops

```yaml
- name: Create admin users
  ansible.builtin.user:
    name: "{{ item.name }}"
    shell: "{{ item.shell }}"
    groups: [sudo]
    append: true
  loop: "{{ admin_users }}"
  loop_control:
    label: "{{ item.name }}"             # keep output short

- name: Create app folders
  ansible.builtin.file:
    path: "/opt/apps/{{ item }}"
    state: directory
    mode: "0755"
  loop: [shop, blog, api]
```
Many modules take a **list directly** — faster than a loop: `apt: name: "{{ common_packages }}"`.

## 📖 Lesson 3.5 — `block`, `rescue`, `always`

Like try/except/finally in Python:
```yaml
- name: Deploy with a safety net
  block:
    - name: Download the release
      ansible.builtin.get_url:
        url: "https://releases.example.com/app-{{ version }}.tar.gz"
        dest: /tmp/app.tar.gz
  rescue:
    - name: Tell someone
      ansible.builtin.debug:
        msg: "download failed on {{ inventory_hostname }} — keeping the old version"
  always:
    - name: Clean up
      ansible.builtin.file:
        path: /tmp/app.tar.gz
        state: absent
```

## 📖 Lesson 3.6 — Running on the control node

```yaml
- name: Write a report on MY machine
  ansible.builtin.copy:
    content: "{{ report_text }}"
    dest: "./reports/{{ inventory_hostname }}.txt"
  delegate_to: localhost
  become: false
```

---

## ⚠️ Common mistakes
- Putting `{{ }}` inside `when:` (it's already a Jinja2 expression)
- Unquoted values that start with `{{` in YAML
- Variables defined in five places with no idea which wins → keep a convention (defaults in roles, environment
  differences in group_vars)
- `command`/`shell` tasks without `changed_when` → always "changed"
- Using `ignore_errors: true` instead of real error handling

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — playbooks + `group_vars/` + `host_vars/`.

### Lab 1 ⭐ — group_vars and host_vars
Create `group_vars/all.yml` (common packages, admin users), `group_vars/web.yml` (web packages, site title) and
`host_vars/db1.yml` (a `backup_hour`). Show what web1 and db1 get with `ansible-inventory --host <h> --vars`.

### Lab 2 ⭐⭐ — Users and packages
`users.yml`: install `common_packages` everywhere and `web_packages` only on web; create every `admin_users` entry
with a loop; create `/opt/apps/<name>` for a list of apps; remove a user listed in `removed_users`.

### Lab 3 ⭐⭐ — Fact report
`facts_report.yml`: for every host, write `reports/<host>.txt` **on your laptop** with OS, kernel, vCPUs, RAM and
groups. Then one combined `reports/summary.txt` built from `hostvars` (`run_once: true`).

### Lab 4 ⭐⭐⭐ — Safe change
`maintenance.yml`: if `/etc/maintenance` exists on a host, skip it with a message; otherwise run a `block` that
"deploys" (writes a version file and validates it with a command); in `rescue`, restore the previous version file;
in `always`, record the result in `/var/log/deploys.log`. Trigger the rescue path with `-e deploy_version=broken`.

---

## ✅ Checkpoint
- [ ] I organise variables in group_vars/host_vars and know the precedence order
- [ ] I can use facts and magic variables like `group_names` and `hostvars`
- [ ] I can `register` results and use `when`, `changed_when`, `failed_when`
- [ ] I can loop, and handle failures with block/rescue/always

👉 Next: [Module 04 — Templates & Handlers](../04-templates-and-handlers/README.md)
