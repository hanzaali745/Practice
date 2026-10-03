#!/usr/bin/env bash
# Lab 1 — quality gate for a Terraform folder: fmt, validate, tflint
# Usage: ./tf_checks.sh DIR
set -uo pipefail

dir="${1:?Usage: $0 DIR}"
config="$(cd "$(dirname "$0")" && pwd)/.tflint.hcl"
failed=0

step() {
    local name="$1"; shift
    if output=$("$@" 2>&1); then
        echo "✅ $name"
    else
        echo "❌ $name"
        head -n 20 <<< "$output" | sed 's/^/     /'
        failed=$((failed + 1))
    fi
}

cd "$dir" || exit 1
step "terraform fmt"      terraform fmt -check -recursive
step "terraform init"     terraform init -backend=false -input=false -no-color
step "terraform validate" terraform validate -no-color
if command -v tflint > /dev/null; then
    step "tflint init" tflint --init --config "$config"
    step "tflint"      tflint --config "$config" --no-color
else
    echo "⚠️  tflint not installed — skipped (https://github.com/terraform-linters/tflint)"
fi

(( failed == 0 )) && echo "🎉 all checks passed" || echo "$failed check(s) failed"
exit "$failed"
