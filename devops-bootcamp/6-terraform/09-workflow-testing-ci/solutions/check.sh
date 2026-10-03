#!/usr/bin/env bash
# Run Module 09's labs: quality gate + both test suites. Leaves nothing behind.
set -euo pipefail
cd "$(dirname "$0")"
trap 'rm -rf ./*/.terraform ./*/.terraform.lock.hcl ./*/test-out ./*/terraform.tfstate*' EXIT

echo "######## Lab 1 — quality gate on webapp-tests"
./tf_checks.sh webapp-tests

echo "######## Lab 2 — terraform test (webapp module)"
(cd webapp-tests && terraform test -no-color)

echo "######## Lab 3 — terraform test with a mocked AWS provider"
(cd state-bucket-tests && terraform init -input=false -no-color > /dev/null && terraform test -no-color)
