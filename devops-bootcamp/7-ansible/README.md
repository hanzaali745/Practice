# ⚙️ Phase 7: Ansible

> **Before you start:** finish Phases 4–6 and install Ansible in your venv
> ([Part 2 of the Ubuntu setup](../00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md)).
> **It's free and local:** every lab runs against the [practice fleet](lab-fleet/README.md) — three Ubuntu 24.04
> "servers" (systemd + SSH) in Docker on your laptop. Reset it whenever you like.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [Inventory & Ad-hoc Commands](01-inventory-and-adhoc/README.md) | 🟢 | inventories, `ansible.cfg`, ad-hoc commands, become, facts |
| 02 | [Playbooks](02-playbooks/README.md) | 🟢 | core modules, `--check --diff`, tags, idempotence |
| 03 | [Variables, Facts, Conditionals & Loops](03-variables-facts-loops/README.md) | 🟡 | group/host vars, precedence, `register`/`when`/`loop`, block/rescue |
| 04 | [Templates & Handlers](04-templates-and-handlers/README.md) | 🟡 | Jinja2, `validate`, handlers, apps as systemd services, nginx |
| 05 | [Roles & Collections](05-roles-and-collections/README.md) | 🔴 | roles, defaults, argument specs, collections, `requirements.yml` |
| 06 | [Vault & Secrets](06-vault-and-secrets/README.md) | 🔴 | ansible-vault, `no_log`, vault IDs, rotation, secret managers |
| 07 | [Testing & Quality](07-testing-and-quality/README.md) | 🔴 | yamllint, ansible-lint, Molecule, quality gate, CI |
| 08 | [Ansible Capstone](08-capstone/README.md) | 🏆 | a tested multi-tier platform with rolling releases and rollback |

## Ansible cheat sheet

```bash
ansible-inventory --graph | --host web1          ansible all -m ping
ansible web -b -m apt -a "name=htop state=present"
ansible-playbook site.yml --check --diff         ansible-playbook site.yml --syntax-check
ansible-playbook site.yml --limit web1 --tags app -v
ansible-playbook site.yml -e "var=value"         ansible-playbook site.yml --list-tasks
ansible-doc -l | ansible-doc MODULE              ansible-galaxy role init roles/NAME
ansible-galaxy install -r requirements.yml       ansible-vault create|edit|view|encrypt|rekey FILE
ansible-vault encrypt_string 'value' --name var  ansible-lint     yamllint .     molecule test -s NAME
```

```yaml
- name: Play                     # hosts + tasks
  hosts: web
  become: true
  serial: 1                      # rolling: one host at a time
  tasks:
    - name: Task
      ansible.builtin.template: { src: x.j2, dest: /etc/x, mode: "0644", validate: "cmd -t %s" }
      notify: Reload x           # → handler, runs once at the end, only if changed
      when: "'web' in group_names"
      loop: "{{ items }}"
      register: result
      changed_when: false
      no_log: true
  handlers:
    - name: Reload x
      ansible.builtin.service: { name: x, state: reloaded }
```
Precedence (simplified, low → high): role defaults < `group_vars/all` < `group_vars/GROUP` < `host_vars/HOST` <
play vars < role `vars/` < task vars < `set_fact`/`register` < `-e` extra vars (always win).

## 🏅 Ansible expert checklist

You're "expert level" when you can do all of these **without notes**:

- [ ] Explain agentless push, modules, idempotence, and when to use Ansible vs Terraform vs a shell script
- [ ] Write INI/YAML inventories with groups, children and variables, and use host patterns
- [ ] Write playbooks with FQCN modules that report `changed=0` on the second run
- [ ] Organise variables in group_vars/host_vars and predict which value wins
- [ ] Use facts, `register`, `when`, `loop`, `block`/`rescue`/`always`, `delegate_to` and `run_once`
- [ ] Template configs with Jinja2, validate critical files, and use handlers instead of restarts in tasks
- [ ] Build roles with defaults and argument specs; pin collections in `requirements.yml`
- [ ] Keep secrets in Vault, out of logs (`no_log`, `diff: false`) and out of process lists
- [ ] Make playbooks dry-run friendly (`--check --diff` works on a fresh server)
- [ ] Test with yamllint, ansible-lint (production profile) and Molecule, and run them in CI
- [ ] Roll out changes safely with `serial`, `max_fail_percentage`, health checks and automatic rollback

👉 Start: [Module 01 — Inventory & Ad-hoc Commands](01-inventory-and-adhoc/README.md)
