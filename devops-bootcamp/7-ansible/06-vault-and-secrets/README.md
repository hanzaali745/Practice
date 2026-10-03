# Ansible Module 06 — Vault & Secrets 🔴

## 🎯 Objectives
- Encrypt secrets with **Ansible Vault** (files and single values) and commit them safely
- Use the `vars.yml` → `vault.yml` naming pattern so secrets stay discoverable
- Keep secrets out of logs and diffs with `no_log` and `diff: false`
- Use **vault IDs** for per-environment passwords, and rotate them with `rekey`
- Know when to use an external secret manager instead

## 🧠 Why DevOps engineers care
Every real deployment needs passwords, API tokens and keys. Plain-text secrets in Git are one of the most common
causes of breaches — and bots scan public repos for them within minutes. Vault lets the secret live next to the
code that uses it, encrypted, so the playbook stays reviewable and reproducible.

---

## 📖 Lesson 6.1 — Encrypt a file

```bash
ansible-vault create group_vars/all/vault.yml     # opens $EDITOR, saves encrypted
ansible-vault edit   group_vars/all/vault.yml     # decrypt → edit → re-encrypt
ansible-vault view   group_vars/all/vault.yml
ansible-vault encrypt secrets.yml                 # encrypt an existing file in place
ansible-vault decrypt secrets.yml                 # ⚠️ writes plain text back to disk
```
What Git sees:
```
$ANSIBLE_VAULT;1.1;AES256
35393864653963386334356533383761343363633931326562663638376162643664356137653736
...
```
Run playbooks with the password:
```bash
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault-pass   # or:
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault-pass
```
The password file can also be an **executable script** that prints the password, e.g. fetched from your
password manager or a CI secret — then it never sits on disk at all.

## 📖 Lesson 6.2 — The `vars.yml` → `vault.yml` pattern

```
group_vars/all/
├── vars.yml      # redis_password: "{{ vault_redis_password }}"   ← plain, greppable
└── vault.yml     # vault_redis_password: "..."                     ← encrypted
```
A folder named after a group (`group_vars/all/`) loads **every** file inside it. Anyone can search for
`redis_password` and see where it comes from; only people with the password can read the value.

## 📖 Lesson 6.3 — Encrypt one value

```bash
ansible-vault encrypt_string 'S3cr3t-Value' --name 'vault_api_key'
```
```yaml
vault_api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          6365373536363432...
```
Paste it into any normal vars file. Handy for one secret, but whole-file encryption is easier to review and rotate.

## 📖 Lesson 6.4 — Don't leak it in the output

```yaml
- name: Write the Redis configuration
  ansible.builtin.template:
    src: redis.conf.j2
    dest: /etc/redis/redis.conf
    mode: "0640"            # not world-readable
  diff: false               # --diff would print the password
  no_log: true              # the task result would too (also hides it from -vvv)

- name: Redis answers with the password
  ansible.builtin.command: redis-cli ping
  environment:
    REDISCLI_AUTH: "{{ redis_password }}"   # not `-a PASSWORD`: arguments show up in `ps`
  no_log: true
```
`no_log` also hides useful error messages — use it on the tasks that touch secrets, not everywhere.
Argument specs can mark an option `no_log: true` too.

## 📖 Lesson 6.5 — Vault IDs and rotation

Different passwords per environment, so a dev laptop can never decrypt prod:
```bash
ansible-vault encrypt --vault-id prod@prompt group_vars/prod/vault.yml
ansible-playbook site.yml --vault-id dev@~/.vault-dev --vault-id prod@prompt
ansible-vault rekey --vault-id prod@old-pass --new-vault-id prod@new-pass group_vars/prod/vault.yml
```
The header then names the ID: `$ANSIBLE_VAULT;1.2;AES256;prod`. Rotate the vault password when someone leaves
the team — **and rotate the secrets themselves**, because they may have copied them.

## 📖 Lesson 6.6 — When to use a real secret manager

Vault is great for small and medium teams. At scale, secrets live in a **secret manager** (HashiCorp Vault,
AWS Secrets Manager, Azure Key Vault) with audit logs and automatic rotation, and Ansible reads them at run time:
```yaml
db_password: "{{ lookup('amazon.aws.aws_secret', 'prod/db/password') }}"
db_password: "{{ lookup('community.hashi_vault.vault_kv2_get', 'db', engine_mount_point='secret').secret.password }}"
```

---

## ⚠️ Common mistakes
- Committing the vault password file (add `.vault-pass*` to `.gitignore` — see the solutions)
- `ansible-vault decrypt` then forgetting to re-encrypt → plain text in the next commit
- Secrets printed by `debug`, `--diff` or `-vvv` → `no_log: true` and `diff: false`
- Secrets on the command line (`-a password`, `-e password=...`) → visible in `ps` and shell history
- One password for every environment, never rotated

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). They reuse the roles from Module 05 (see `roles_path` in `ansible.cfg`)
and add a `redis` role. **Lab-only** vault password: `bootcamp-lab-vault` — `./vault_demo.sh` writes it to
`.vault-pass` (git-ignored) for you.

### Lab 1 ⭐ — Vault basics
Create, view, edit, encrypt, decrypt and `encrypt_string` a secret. Look at the encrypted file with `cat` and with
`git diff`. Run [`solutions/vault_demo.sh`](solutions/vault_demo.sh) for a guided tour.

### Lab 2 ⭐⭐ — Redis with a vaulted password
Write a `redis` role (install, config template with `requirepass`, restart handler, a `redis-cli ping` check using
`REDISCLI_AUTH`). Keep the password in `group_vars/all/vault.yml` with the `vars.yml` → `vault.yml` pattern. The role
must refuse to run with an empty or short password (`assert`).

### Lab 3 ⭐⭐ — Connect the app
Point demo-app at Redis (`demo_app_redis_host: db1`, `demo_app_redis_password: "{{ redis_password }}"`).
`curl localhost:8081/visits` and `curl localhost:8082/visits` must share one counter (`"backend": "redis"`).
Then prove nothing leaked: `ansible-playbook site.yml --diff -v > run.log` and `grep` for the password → 0 matches.

### Lab 4 ⭐⭐⭐ — Guard rails
Write `check_vault_files.sh` that fails if any `vault.yml` in the repo is not encrypted or a vault password file is
tracked by Git; hook it into `.git/hooks/pre-commit`. Then rotate: `rekey` to a new password, update `.vault-pass`,
and run the playbook again.

---

## ✅ Checkpoint
- [ ] I can encrypt files and single values and run playbooks with a password file
- [ ] I use the `vars.yml` → `vault.yml` pattern and never commit the password
- [ ] My secret-handling tasks use `no_log`, `diff: false` and environment variables, not arguments
- [ ] I can use vault IDs, rotate with `rekey`, and explain when a secret manager is the better tool

👉 Next: [Module 07 — Testing & Quality](../07-testing-and-quality/README.md)
