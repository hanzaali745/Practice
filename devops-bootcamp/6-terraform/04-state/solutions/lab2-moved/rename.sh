#!/usr/bin/env bash
# Lab 2 — rename random_string.suffix → app_suffix, first WITHOUT then WITH a moved block
set -euo pipefail
cd "$(dirname "$0")"

sed -i 's/resource "random_string" "suffix"/resource "random_string" "app_suffix"/' main.tf
echo "== plan WITHOUT moved block (look: destroy + create!)"
terraform plan -no-color | grep -E "will be (created|destroyed)|Plan:"

cat >> main.tf <<'EOF'

moved {
  from = random_string.suffix
  to   = random_string.app_suffix
}
EOF
echo "== plan WITH moved block"
terraform plan -no-color | grep -E "has moved|Plan:"
terraform apply -auto-approve -no-color | grep -E "Apply complete"
terraform state list
