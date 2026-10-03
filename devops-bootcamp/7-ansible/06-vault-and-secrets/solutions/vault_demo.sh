#!/usr/bin/env bash
# Module 06 — a guided tour of ansible-vault. Safe to re-run: works on throwaway copies in a temp folder.
set -euo pipefail
cd "$(dirname "$0")"

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

# LAB ONLY: the course publishes this password so you can run the solutions.
# Real projects get the password from a password manager / CI secret, never from Git.
[[ -f .vault-pass ]] || { printf '%s\n' 'bootcamp-lab-vault' > .vault-pass; chmod 600 .vault-pass; }
export ANSIBLE_VAULT_PASSWORD_FILE="$PWD/.vault-pass"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

say "1. An encrypted file is safe to commit — this is all Git sees"
head -3 group_vars/all/vault.yml

say "2. View it (needs the password)"
ansible-vault view group_vars/all/vault.yml | sed -E 's/(: ").{4}.*"/\1****"  (hidden by this script)/'

say "3. Encrypt a new file, then decrypt it"
printf 'api_token: "abc123"\n' > "$tmp/secrets.yml"
ansible-vault encrypt "$tmp/secrets.yml"
head -1 "$tmp/secrets.yml"
ansible-vault decrypt "$tmp/secrets.yml" --output - | head -1

say "4. Encrypt ONE value to paste into a normal vars file"
ansible-vault encrypt_string 'S3cr3t-Value' --name 'vault_api_key' | head -3
echo "   ..."

say "5. Vault IDs: a different password per environment"
# (env -u: use ONLY the prod password here, not the default one exported above)
printf 'prod-password\n' > "$tmp/prod-pass"
printf 'db_password: "prod-only"\n' > "$tmp/prod.yml"
env -u ANSIBLE_VAULT_PASSWORD_FILE ansible-vault encrypt --vault-id "prod@$tmp/prod-pass" "$tmp/prod.yml"
head -1 "$tmp/prod.yml"       # the header names the vault ID: ...;1.2;AES256;prod

say "6. Rotate the password (rekey)"
printf 'new-password\n' > "$tmp/new-pass"
env -u ANSIBLE_VAULT_PASSWORD_FILE ansible-vault rekey --vault-id "prod@$tmp/prod-pass" --new-vault-id "prod@$tmp/new-pass" "$tmp/prod.yml"
env -u ANSIBLE_VAULT_PASSWORD_FILE ansible-vault view --vault-id "prod@$tmp/new-pass" "$tmp/prod.yml"

say "7. Use the secret in a play — and keep it out of the logs with no_log"
ansible localhost -m ansible.builtin.debug -a 'msg="password length is {{ vault_redis_password | length }}"' \
    -e @group_vars/all/vault.yml 2>/dev/null | tail -3

say "Done. Deploy the real thing with:  ANSIBLE_VAULT_PASSWORD_FILE=.vault-pass ansible-playbook site.yml"
