# Lab 2 — step 1: apply this as-is. Step 2: run ./rename.sh to rename the resource with a moved block.
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
