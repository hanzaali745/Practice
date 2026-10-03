# Ansible Module 01 — Inventory & Ad-hoc Commands 🟢

## 🎯 Objectives
- Explain what Ansible is and how it differs from Terraform and shell scripts
- Start the **practice fleet** (3 Ubuntu servers in Docker)
- Write an **inventory** with groups and variables, and an `ansible.cfg`
- Run **ad-hoc commands** on many servers at once
- Use `become` (sudo), facts, and the most common modules

## 🧠 Why DevOps engineers care
Terraform creates servers; **Ansible configures them**: install packages, write config files, create users,
start services, deploy apps, patch hundreds of machines. It needs nothing installed on the servers except SSH
and Python ("agentless"), uses readable YAML, and is everywhere — on-prem, cloud, network devices. And it's
written in Python, which you know from Phase 1.

---

## 📖 Lesson 1.1 — How Ansible works

```
 your laptop (control node)                    managed nodes
 ┌──────────────────────────┐   SSH    ┌─────────────────────────┐
 │ inventory  (which hosts) │ ───────► │ web1  (Python + SSH)    │
 │ playbook   (what to do)  │ ───────► │ web2                    │
 │ ansible-playbook         │ ───────► │ db1                     │
 └──────────────────────────┘          └─────────────────────────┘
```
For each task Ansible copies a small Python program (a **module**) to the host, runs it, and gets back JSON:
`ok` (already correct), `changed` (Ansible changed something), `failed`, or `skipped`.

| | Shell script | Terraform | Ansible |
|--|-------------|-----------|---------|
| Best at | one-off glue | **creating** infrastructure (cloud APIs) | **configuring** servers (inside the OS) |
| Model | imperative steps | declarative + state file | declarative tasks, **no state file** |
| Idempotent? | only if you're careful | yes | yes (modules check before changing) |

## 📖 Lesson 1.2 — Start the practice fleet

```bash
cd ~/Practice/devops-bootcamp/7-ansible/lab-fleet
./fleet.sh up          # first time: a few minutes to build
./fleet.sh status
./fleet.sh ssh web1    # it's a real Ubuntu "server" — look around, then `exit`
```
Details: [`lab-fleet/README.md`](../lab-fleet/README.md). Ansible itself is in your venv
(`source ~/venvs/devops/bin/activate`; installed in Part 2 of the setup).

## 📖 Lesson 1.3 — Inventory

`inventory.ini` (from the fleet folder):
```ini
[web]
web1 ansible_port=2221
web2 ansible_port=2222

[db]
db1 ansible_port=2223

[fleet:children]        # a group of groups
web
db

[fleet:vars]            # variables for every host in "fleet"
ansible_host=127.0.0.1
ansible_user=devops
ansible_ssh_private_key_file={{ inventory_dir }}/.ssh/id_ed25519
```
Real servers usually just need `web1.example.com` or `web1 ansible_host=10.0.1.10`.

The same in YAML (`inventory.yaml`):
```yaml
all:
  children:
    web:
      hosts:
        web1: { ansible_port: 2221 }
        web2: { ansible_port: 2222 }
    db:
      hosts:
        db1: { ansible_port: 2223 }
```
Built-in groups: `all` (every host) and `ungrouped`.

```bash
ansible-inventory -i inventory.ini --graph          # tree of groups and hosts
ansible-inventory -i inventory.ini --host web1      # all variables for one host
```

## 📖 Lesson 1.4 — `ansible.cfg`

Ansible reads `ansible.cfg` from the **current folder** first. Each module's `solutions/` has one:
```ini
[defaults]
inventory = ../../lab-fleet/inventory.ini
host_key_checking = False        # LAB ONLY: the fleet's host keys change on every reset
callback_result_format = yaml    # readable output
retry_files_enabled = False

[ssh_connection]
pipelining = True                # faster: fewer SSH round trips
```
```bash
ansible --version        # shows which config file is in use
ansible-config dump --only-changed
```

## 📖 Lesson 1.5 — Ad-hoc commands

`ansible <pattern> -m <module> -a "<arguments>"`:

```bash
ansible fleet -m ping                          # can I reach every host? (Ansible ping, not ICMP)
ansible web -m command -a "uptime"             # run a command (no shell features)
ansible db1 -m shell -a "df -h / | tail -1"    # shell module: pipes, redirects, $VARS
ansible fleet -a "hostname"                    # -m command is the default
ansible 'web:!web2' -a "whoami"                # patterns: web except web2 (also web:db, web:&prod)
```

**Become** = run as root via sudo:
```bash
ansible fleet -b -m apt -a "name=htop state=present update_cache=true"   # install a package
ansible fleet -b -m apt -a "name=htop state=present"                      # again → "ok", not "changed"!
ansible fleet -b -m user -a "name=alice shell=/bin/bash"
ansible web -b -m copy -a "content='Managed by Ansible\n' dest=/etc/motd"
ansible web -b -m service -a "name=ssh state=started enabled=true"
ansible fleet -m setup -a "filter=ansible_distribution*"                  # facts about the hosts
ansible fleet -f 10 -a "uptime"                                           # -f = forks (parallelism)
```

The second `apt` run says **ok** instead of **changed** — that's **idempotence**: modules check the current
state and only act if needed. That's what makes it safe to run Ansible again and again.

## 📖 Lesson 1.6 — Finding modules and docs

```bash
ansible-doc -l | grep -i apt          # list modules
ansible-doc apt                        # full documentation + EXAMPLES at the bottom ⭐
ansible-doc -s user                    # short snippet
```
Prefer real modules over `command`/`shell` — modules are idempotent and report `changed` correctly;
`command` always reports `changed`.

---

## ⚠️ Common mistakes
- Running `ansible` from a folder without the right `ansible.cfg` → "No inventory was parsed"
- Using `shell`/`command` when a module exists (`apt`, `user`, `copy`, `service`...)
- Forgetting `-b` for tasks that need root → permission denied
- Turning off host key checking on **real** servers (only OK for this throwaway lab)

---

## 🧪 Labs
Work in `my-work/ansible/`. Solutions: [`solutions/`](solutions/) — run `./adhoc_tour.sh` there.

### Lab 1 ⭐ — Meet your fleet
Start the fleet, ping all hosts, print the inventory graph, and show all variables of `db1`.

### Lab 2 ⭐ — Ad-hoc tour
With ad-hoc commands only: show the uptime and kernel of every host, the free disk space of the `web` group, and
the Ubuntu version of each host using facts (`ansible_distribution_version`).

### Lab 3 ⭐⭐ — Idempotence
Install `tree` and `jq` on all hosts with `apt`; run the same command again and compare `changed` vs `ok`. Then use
`command -a "apt-get install -y tree"` twice — why does it always say `changed`?

### Lab 4 ⭐⭐ — Your own inventory
Write `inventory.yaml` for the fleet with the same groups plus a `prod` group containing web2 and db1, and a
variable `env: prod` for that group. Prove it with `ansible-inventory --graph` and
`ansible prod -m debug -a "var=env"`.

---

## ✅ Checkpoint
- [ ] I can explain control node, managed node, module, inventory and idempotence
- [ ] I can write INI and YAML inventories with groups and variables
- [ ] I can run ad-hoc commands with patterns, `-b` and facts
- [ ] I prefer modules over `command`/`shell` and know why

👉 Next: [Module 02 — Playbooks](../02-playbooks/README.md)
