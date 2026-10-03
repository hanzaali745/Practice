# Ansible Module 08 — Ansible Capstone 🏆

> **CEO note:** Configuration management is trusted with every server you own. Your capstone must be something
> I'd let run against production at 3 pm on a Friday: tested, idempotent, no secrets in Git, and a release
> process that stops itself when something goes wrong.

**Definition of Done:**
- [ ] Roles with prefixed, defaulted, validated variables (argument specs); a thin `site.yml`
- [ ] One inventory folder per environment, with `group_vars` and a vaulted secrets file
- [ ] A fresh server goes from nothing to working with **one** command; the second run reports `changed=0`
- [ ] `--check --diff` works on a fresh server, and secrets never appear in output
- [ ] A rolling release playbook (`serial`, `max_fail_percentage`) that verifies each host and rolls back on failure
- [ ] yamllint and ansible-lint (production profile) clean; Molecule tests for at least one role
- [ ] A check script and a CI workflow; a README with usage and a rollback section

---

## Project 1 ⭐⭐⭐ — The demo platform on "real" servers (full reference solution)

The same demo-app you containerised (Phase 4), orchestrated (Phase 5) and described as code (Phase 6) — now
installed the classic way on Linux servers:

```
                     ┌───────────── web1 ─────────────┐
 laptop:8081 ──────► │ nginx ─► demo-app@8001 / @8002 │──┐
                     └────────────────────────────────┘  │     ┌──── db1 ────┐
                     ┌───────────── web2 ─────────────┐  ├───► │ Redis       │
 laptop:8082 ──────► │ nginx ─► demo-app@8001 / @8002 │──┘     │ (password)  │
                     └────────────────────────────────┘        └─────────────┘
   every host: common role — packages, admin users + SSH keys, sudoers, SSH hardening, motd
```

```
platform/
├── ansible.cfg                  # inventory, roles path
├── requirements.yml             # pinned collections
├── inventories/lab/
│   ├── hosts.ini
│   └── group_vars/
│       ├── all/vars.yml         # redis_password: "{{ vault_redis_password }}"
│       ├── all/vault.yml        # 🔒 encrypted
│       ├── web.yml              # app ports, message, version, Redis host
│       └── db.yml
├── roles/
│   ├── common/                  # baseline for every server
│   ├── redis/                   # Redis with requirepass, no_log, health check
│   ├── demo_app/                # systemd template-unit instances, env file 0640
│   └── nginx_proxy/             # load-balancing reverse proxy, nginx -t before reload
├── site.yml                     # converge everything (idempotent)
├── deploy.yml                   # rolling release with verification and automatic rollback
├── molecule/demo_app/           # role test in a throwaway container
├── check.sh                     # the quality gate + end-to-end test
└── .yamllint  .ansible-lint  check_vault_files.sh
```

👉 Reference: [`solutions/platform/`](solutions/platform/) — the lab vault password is `bootcamp-lab-vault`
(`check.sh` writes it to the git-ignored `.vault-pass`).

```bash
cd ~/Practice/devops-bootcamp/7-ansible
lab-fleet/fleet.sh reset                         # fresh servers
cd 08-capstone/solutions/platform
./check.sh                                       # static checks (no servers needed)
export ANSIBLE_VAULT_PASSWORD_FILE=$PWD/.vault-pass
ansible-playbook site.yml --check --diff         # preview on fresh servers
ansible-playbook site.yml                        # build everything
curl localhost:8081/visits; curl localhost:8082/visits    # one shared counter in Redis
./check.sh --e2e --molecule                      # the full gate, as CI would run it
```

### The release process
```bash
ansible-playbook deploy.yml -e release_version=2.1.0
```
`serial: 1` updates web1, verifies every instance reports `2.1.0`, then moves to web2. Simulate a bad release
(a config change that crashes the app):
```bash
ansible-playbook deploy.yml -e release_version=2.2.0 -e '{"release_extra_env": {"REDIS_PORT": "not-a-port"}}'
```
web1 fails its check → the `rescue` restores the previous config and restarts it → `fail` stops the play →
`max_fail_percentage: 0` means web2 is **never touched**. Users only ever saw working servers.

### Rollback & source of truth
After a successful release, commit the new `demo_app_version` to `inventories/lab/group_vars/web.yml` — the
inventory in Git is the source of truth, and the next `site.yml` run converges every server back to it. To roll
back a release that passed its checks but is still wrong: revert that commit and run `site.yml`.

**Stretch goals:** a second environment (`inventories/staging` with its own vault ID) · a `patch.yml` that runs
`apt upgrade` with `serial: 1` and reboots only when `/var/run/reboot-required` exists · a Molecule scenario for
the `redis` role · `community.general.ufw` firewall rules in `common` (test on a real VM).

---

## Project 2 ⭐⭐⭐ — Terraform + Ansible handoff
The classic pattern: **Terraform provisions, Ansible configures.**
1. Terraform (Phase 6) creates the servers — EC2 instances on AWS, or containers with the
   `kreuzwerker/docker` provider for a free local version — and writes an inventory with `templatefile`:
   ```hcl
   resource "local_file" "inventory" {
     filename = "${path.module}/../ansible/inventories/tf/hosts.ini"
     content  = templatefile("${path.module}/hosts.ini.tftpl", { web = aws_instance.web[*].public_ip })
   }
   ```
2. Ansible runs `site.yml` against `inventories/tf/`.
3. Bonus: replace the generated file with a **dynamic inventory** plugin (`amazon.aws.aws_ec2`) that finds
   hosts by tag, so new servers are picked up automatically.

## Project 3 ⭐⭐ — Operations toolkit
Playbooks the on-call engineer runs: `facts_report.yml` (inventory of OS/RAM/disk to CSV), `rotate_ssh_keys.yml`
(add the new key, test it, then remove the old one), `disk_cleanup.yml` (old logs and apt caches, only when the
disk is over 80%), and `restart_service.yml -e service=nginx` with `serial: 1` and a health check.

## Project 4 ⭐⭐⭐ — Publish a role
Turn `demo_app` into a stand-alone role repository: README with every variable, `meta/argument_specs.yml`,
Molecule tests in GitHub Actions, semantic version tags. Install it in your platform project through
`requirements.yml` (`src: git+https://github.com/<you>/ansible-role-demo-app.git`, `version: v1.0.0`).

---

## 🎓 Ansible phase complete!
Tick the [Ansible expert checklist](../README.md#-ansible-expert-checklist). Look at how far you've come: Python,
Shell, Bash, Docker, Kubernetes, Terraform and Ansible — the core toolbox of a DevOps engineer. Next you'll automate
how all of it ships: every push tested, built, scanned and deployed by a pipeline.

👉 Next phase: [Phase 8 — CI/CD](../../8-cicd/README.md)
