# Ansible Module 02 — Playbooks 🟢

## 🎯 Objectives
- Write playbooks: plays, tasks, modules, `become`
- Use the core modules: `apt`, `copy`, `file`, `lineinfile`, `user`, `service`, `uri`
- Preview changes safely with `--check --diff`
- Run parts of a playbook with `--tags`, `--limit` and `--start-at-task`
- Prove a playbook is **idempotent**

## 🧠 Why DevOps engineers care
Ad-hoc commands are for quick jobs; **playbooks** are how you codify server configuration so it's reviewed,
versioned and repeatable — the Ansible equivalent of a Dockerfile or a Terraform config. A good playbook can
be run every day against every server and only ever changes what has drifted.

---

## 📖 Lesson 2.1 — Anatomy of a playbook

`site.yml`:
```yaml
---
- name: Configure web servers          # a PLAY: which hosts + what to do
  hosts: web
  become: true                          # run tasks with sudo

  tasks:                                # TASKS run in order, on all hosts in parallel
    - name: Install nginx               # always name your tasks — it's your log
      ansible.builtin.apt:              # module (fully qualified collection name, FQCN)
        name: nginx
        state: present
        update_cache: true
        cache_valid_time: 3600          # don't refresh the apt cache more than once an hour

    - name: Make sure nginx is running and starts at boot
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
```
```bash
ansible-playbook site.yml
```
```
PLAY [Configure web servers] ****************************************
TASK [Gathering Facts] ***********************************************
ok: [web1]
TASK [Install nginx] *************************************************
changed: [web1]
...
PLAY RECAP ***********************************************************
web1  : ok=3  changed=2  unreachable=0  failed=0  skipped=0
```
Run it again: `changed=0`. That's the goal.

## 📖 Lesson 2.2 — Core modules

```yaml
    - name: Create a deploy user
      ansible.builtin.user:
        name: deploy
        shell: /bin/bash
        groups: [sudo]
        append: true

    - name: Create the app directory
      ansible.builtin.file:
        path: /opt/myapp
        state: directory            # also: file, absent, link, touch
        owner: deploy
        mode: "0755"                # always QUOTE file modes

    - name: Write a small config file
      ansible.builtin.copy:
        dest: /opt/myapp/app.env
        content: |
          APP_ENV=production
          PORT=8000
        mode: "0640"

    - name: Copy a file from the control node
      ansible.builtin.copy:
        src: files/index.html       # relative to the playbook's files/ folder
        dest: /var/www/html/index.html

    - name: Ensure one line in a file (e.g. harden SSH)
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
        validate: /usr/sbin/sshd -t -f %s    # refuse to write a broken sshd_config!

    - name: Check the website answers
      ansible.builtin.uri:
        url: http://localhost/
        status_code: 200
```

## 📖 Lesson 2.3 — Several plays in one playbook

```yaml
- name: Baseline for every server
  hosts: fleet
  become: true
  tasks:
    - name: Install basic tools
      ansible.builtin.apt:
        name: [curl, vim, htop, tree]
        state: present

- name: Web servers
  hosts: web
  become: true
  tasks:
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
```

## 📖 Lesson 2.4 — Dry runs: `--check` and `--diff`

```bash
ansible-playbook site.yml --check          # what WOULD change (nothing is changed)
ansible-playbook site.yml --check --diff   # ...and show file diffs line by line ⭐
ansible-playbook site.yml --syntax-check   # YAML/structure only
ansible-playbook site.yml --list-tasks     # what would run
```
Always `--check --diff` before running against production.

> ⚠️ **Check-mode gotcha:** in `--check` mode nothing is really installed, so a later task that depends on an
> earlier change (e.g. "start nginx" after "install nginx") fails on a fresh server. Make such tasks
> dry-run-friendly: `ignore_errors: "{{ ansible_check_mode }}"` or `when: not ansible_check_mode` — see
> [`solutions/webservers.yml`](solutions/webservers.yml).

## 📖 Lesson 2.5 — Running only part of a playbook

```yaml
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
      tags: [nginx, packages]
```
```bash
ansible-playbook site.yml --tags nginx           # only tasks tagged nginx
ansible-playbook site.yml --skip-tags packages
ansible-playbook site.yml --limit web1           # only some hosts
ansible-playbook site.yml --start-at-task "Make sure nginx is running"
ansible-playbook site.yml -v / -vvv              # more detail (great for debugging)
```

## 📖 Lesson 2.6 — YAML gotchas

```yaml
mode: 0644        # ❌ YAML reads this as the NUMBER 420 → wrong permissions. Use "0644"
enabled: yes      # works, but use true/false (yamllint/ansible-lint prefer it)
command: echo {{ x }}       # ❌ a value starting with {{ must be quoted
command: "echo {{ x }}"    # ✅
```

---

## ⚠️ Common mistakes
- Unnamed tasks → unreadable output
- `command`/`shell` for things modules do → not idempotent, always "changed"
- Unquoted file modes
- Not running `--check --diff` first
- `lineinfile` on complex files (use `template` — Module 04)

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) (with the fleet up, run from that folder).

### Lab 1 ⭐ — First playbook
Write `baseline.yml` for all hosts: install `curl, vim, htop, tree`; create user `deploy` with a home and bash;
create `/opt/apps` owned by `deploy`; write `/etc/motd` saying "Managed by Ansible — changes will be overwritten".
Run it twice: the second run must report `changed=0`.

### Lab 2 ⭐⭐ — Web servers
Write `webservers.yml`: install nginx on the `web` group, write a custom `/var/www/html/index.html` that says which
host it is (use `{{ inventory_hostname }}`), make sure nginx runs, and check it with `uri`. From your laptop:
`curl localhost:8081` and `curl localhost:8082`.

### Lab 3 ⭐⭐ — Safe changes
Add a `lineinfile` task (with `validate`) that sets `PermitRootLogin no` in `/etc/ssh/sshd_config`. Preview with
`--check --diff`, then apply. Tag the nginx tasks `web` and run only them with `--tags`.

### Lab 4 ⭐⭐⭐ — Idempotence test script
Write `idempotence.sh PLAYBOOK` that runs a playbook twice and fails if the second run has `changed=` anything other
than 0 for any host (parse the `PLAY RECAP`). This exact check is what CI pipelines do for Ansible.

---

## ✅ Checkpoint
- [ ] I can write plays with named tasks, `become`, and FQCN modules
- [ ] I use apt, copy, file, lineinfile, user, service and uri confidently
- [ ] I always preview with `--check --diff` and can run subsets with tags/limit
- [ ] My playbooks report `changed=0` on the second run

👉 Next: [Module 03 — Variables, Facts, Conditionals & Loops](../03-variables-facts-loops/README.md)
