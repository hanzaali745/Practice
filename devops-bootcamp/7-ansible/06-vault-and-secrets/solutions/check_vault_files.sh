#!/usr/bin/env bash
# Module 06 Lab 4 — fail if any vault file is NOT encrypted. Use it as a pre-commit hook or CI step:
#   ln -s ../../devops-bootcamp/7-ansible/06-vault-and-secrets/solutions/check_vault_files.sh .git/hooks/pre-commit
set -euo pipefail
root=${1:-.}
bad=0
while IFS= read -r -d '' f; do
    if head -1 "$f" | grep -q '^[$]ANSIBLE_VAULT;'; then
        echo "ok        $f"
    else
        echo "PLAINTEXT $f"
        bad=1
    fi
done < <(find "$root" -type f \( -name 'vault.yml' -o -name 'vault.yaml' -o -name '*.vault.yml' \) -print0)

# A vault password file must never be tracked by Git
if git -C "$root" rev-parse --git-dir >/dev/null 2>&1 && git -C "$root" ls-files | grep -q 'vault-pass'; then
    echo "TRACKED   a vault password file is in Git!"
    bad=1
fi
exit "$bad"
