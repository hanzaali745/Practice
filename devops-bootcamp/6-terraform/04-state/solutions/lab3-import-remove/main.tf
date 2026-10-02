# Lab 3 — step 1: import an existing value. (Step 2: rm-import.sh switches to a removed block.)
import {
  to = random_string.legacy
  id = "abc123"
}

# This block must MATCH the existing object, or Terraform will replace it.
# (Generated with: terraform plan -generate-config-out=generated.tf — then trimmed to the non-defaults.)
resource "random_string" "legacy" {
  length = 6
}
