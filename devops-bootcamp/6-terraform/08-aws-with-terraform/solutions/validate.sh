#!/usr/bin/env bash
# Validate both AWS configs against the AWS provider schema — no AWS account or credentials needed.
set -euo pipefail
cd "$(dirname "$0")"

for dir in web-server state-bucket; do
    echo "== $dir"
    (
        cd "$dir"
        terraform fmt -check
        terraform init -backend=false -input=false -no-color > /dev/null
        terraform validate -no-color
    )
done
