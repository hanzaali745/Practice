#!/usr/bin/env bash
# Validate everything and run the module's tests (mocked — no cluster needed). Leaves nothing behind.
set -euo pipefail
cd "$(dirname "$0")"
trap 'find . -name .terraform -type d -prune -exec rm -rf {} + ; find . -name .terraform.lock.hcl -delete' EXIT

terraform fmt -recursive -check
echo "✅ formatting"
for dir in modules/demo-platform live/dev live/prod; do
    (cd "$dir" && terraform init -backend=false -input=false -no-color > /dev/null && terraform validate -no-color > /dev/null)
    echo "✅ validate $dir"
done
(cd modules/demo-platform && terraform test -no-color)
