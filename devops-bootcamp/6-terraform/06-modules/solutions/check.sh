#!/usr/bin/env bash
# Apply dev and prod, show the generated files, then run the refactoring lab. Leaves nothing behind.
set -euo pipefail
cd "$(dirname "$0")"

clean() { rm -rf envs/*/.terraform envs/*/terraform.tfstate* envs/*/.terraform.lock.hcl envs/*/out \
                 refactor/.terraform refactor/terraform.tfstate* refactor/.terraform.lock.hcl refactor/out; }
trap clean EXIT
q() { terraform "$@" -no-color > /dev/null; }

for env in dev prod; do
    echo "######## $env"
    (cd "envs/$env" && q init -input=false && q apply -auto-approve && terraform output -json ports && find out -type f | sort)
done
echo "-- prod nginx site:"
cat envs/prod/out/shop-prod/site.conf

echo "-- invalid module input is rejected:"
bad=$(mktemp -d)
cat > "$bad/main.tf" <<EOF
module "web" {
  source      = "$PWD/modules/webapp"
  name        = "Shop_App"
  environment = "dev"
  out_dir     = "/tmp"
}
EOF
(cd "$bad" && q init -input=false && { terraform plan -no-color 2>&1 || true; } | grep -E "name must be")
rm -rf "$bad"

echo "######## Lab 4 — refactor into the module"
cd refactor
cp main.tf /tmp/refactor-step1.tf
q init -input=false && q apply -auto-approve
cp main.tf.step2 main.tf
q init -input=false
terraform plan -no-color | grep -E "has moved|will be created|will be destroyed|Plan:"
cp /tmp/refactor-step1.tf main.tf
cd ..
echo "🎉 done"
