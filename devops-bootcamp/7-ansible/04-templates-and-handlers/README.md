# Ansible Module 04 — Templates & Handlers 🟡

## 🎯 Objectives
- Generate config files with **Jinja2 templates** (variables, loops, conditionals, filters)
- Validate config **before** it's written (`validate:`)
- Restart/reload services **only when something changed**, with **handlers**
- Deploy an app as a **systemd service** with Ansible
- Put nginx in front of it as a reverse proxy

## 🧠 Why DevOps engineers care
Nearly all server configuration is files: nginx sites, systemd units, app configs, sshd_config. Templates let one
file serve every environment, and handlers make sure a service restarts exactly when — and only when — its config
changed. That's how you avoid both stale config and needless restarts in production.

---

## 📖 Lesson 4.1 — Templates

`templates/site.conf.j2`:
```jinja
# {{ ansible_managed }}
upstream app {
{% for port in app_ports %}
    server 127.0.0.1:{{ port }};
{% endfor %}
}

server {
    listen 80 default_server;
    server_name {{ server_name | default(inventory_hostname) }};

    location / {
        proxy_pass http://app;
        proxy_set_header Host $host;
    }
{% if enable_status_page %}
    location /nginx_status { stub_status; allow 127.0.0.1; deny all; }
{% endif %}
}
```
```yaml
- name: Configure the nginx site
  ansible.builtin.template:
    src: site.conf.j2                    # looked up in ./templates/
    dest: /etc/nginx/sites-available/default
    mode: "0644"
```

Jinja2 cheat sheet:

| Syntax | Meaning |
|--------|---------|
| `{{ var }}` | print a value |
| `{% for x in list %}...{% endfor %}` | loop |
| `{% if cond %}...{% elif %}...{% else %}...{% endif %}` | condition |
| `{{ name \| upper }}`, `{{ list \| join(', ') }}` | filters |
| `{{ port \| default(8000) }}` | default if undefined |
| `{{ ansible_managed }}` | "Ansible managed" banner — tells people not to edit |
| `{# comment #}` | template comment |

## 📖 Lesson 4.2 — Validate before writing

```yaml
- name: Configure sshd
  ansible.builtin.template:
    src: sshd_config.j2
    dest: /etc/ssh/sshd_config
    validate: /usr/sbin/sshd -t -f %s     # %s = the new file; if the check fails, the old file stays
```
A broken `sshd_config` can lock you out of every server at once. `validate` makes that impossible.
(For nginx, which checks its whole config, validate *after* writing with a handler or `nginx -t` — see solutions.)

## 📖 Lesson 4.3 — Handlers

```yaml
  tasks:
    - name: Configure the nginx site
      ansible.builtin.template:
        src: site.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: Reload nginx                 # only fires if this task reports "changed"

  handlers:
    - name: Reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
```
- Handlers run **once**, at the **end of the play**, no matter how many tasks notified them
- If nothing changed, they don't run → no needless restarts
- Force them to run earlier: `- ansible.builtin.meta: flush_handlers`
- Several handlers can listen to one topic: `listen: "web config changed"`

## 📖 Lesson 4.4 — Deploy an app as a systemd service

`templates/demo-app.service.j2`:
```ini
# {{ ansible_managed }}
[Unit]
Description=demo-app instance on port %i
After=network.target

[Service]
User=demoapp
Environment=PORT=%i
EnvironmentFile=/etc/demo-app/demo-app.env
ExecStart=/usr/bin/python3 /opt/demo-app/app.py
Restart=on-failure
NoNewPrivileges=true
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
```
`demo-app@.service` is a **template unit**: `demo-app@8001` runs one instance on port 8001, `demo-app@8002` another.
```yaml
- name: Start one instance per port
  ansible.builtin.systemd_service:
    name: "demo-app@{{ item }}"
    state: started
    enabled: true
    daemon_reload: true
  loop: "{{ app_ports }}"
```

## 📖 Lesson 4.5 — Putting it together

```
 laptop:8081 ──► web1:80 nginx (template) ──► demo-app@8001 ┐  systemd services
                                         └──► demo-app@8002 ┘  (template unit + env file)
```
Change `app_message` in group_vars → the env file changes → handler restarts the app instances → nginx untouched.
Change the number of ports → the nginx template changes → handler reloads nginx. Run again → `changed=0`.

---

## ⚠️ Common mistakes
- Editing files on the server that a template manages (the next run overwrites them — `ansible_managed` warns people)
- `state: restarted` in tasks (restarts on every run) instead of a handler
- Forgetting `daemon_reload` after changing a unit file
- Expecting handlers to run when the play fails halfway (they don't, unless `--force-handlers`)
- No `validate` on critical files like sshd_config and sudoers

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `ansible-playbook site.yml`, then `curl localhost:8081`.

### Lab 1 ⭐ — motd template
Template `/etc/motd` with the hostname, OS, RAM (facts), groups and a warning line that only appears on hosts in `db`.

### Lab 2 ⭐⭐ — demo-app as a service
Deploy `app.py` (from Docker's `app/` folder) to `/opt/demo-app`, a `demoapp` system user, an env file from a template
and the `demo-app@.service` template unit. Run 2 instances per web server (ports 8001–8002).

### Lab 3 ⭐⭐ — nginx reverse proxy with handlers
Template the nginx site to load-balance over the app ports. Use handlers: **restart** the app when its code/env changes,
**reload** nginx when the site changes. Prove: `curl localhost:8081` several times shows both instances (different
`PORT`... the hostname is the same, so check `/visits` counts or the logs), and a second run reports `changed=0`.

### Lab 4 ⭐⭐⭐ — Change management
Change `app_message` → only the app handler runs. Change `app_ports` to three ports → nginx reloads and a third
instance starts. Write down which handlers ran each time (`-v` output).

---

## ✅ Checkpoint
- [ ] I can write Jinja2 templates with loops, conditions, filters and defaults
- [ ] I validate critical files before writing them
- [ ] I use handlers (reload vs restart) instead of restarting in tasks
- [ ] I can deploy and manage an app as a systemd service with Ansible

👉 Next: [Module 05 — Roles & Collections](../05-roles-and-collections/README.md)
