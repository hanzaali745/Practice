#!/usr/bin/env bash
# Lab 3 — step 2: stop managing random_string.legacy WITHOUT destroying it
set -euo pipefail
cd "$(dirname "$0")"

cat > main.tf <<'EOF'
# Lab 3 — step 2: forget the resource but don't destroy it
removed {
  from = random_string.legacy
  lifecycle {
    destroy = false
  }
}
EOF
terraform plan -no-color | grep -E "will no longer be managed|Plan:"
terraform apply -auto-approve -no-color | grep -E "Apply complete"
echo "state now: [$(terraform state list)]"
