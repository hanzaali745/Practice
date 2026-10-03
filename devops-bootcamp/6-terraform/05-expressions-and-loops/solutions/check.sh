#!/usr/bin/env bash
# Run every Module 05 lab and show the interesting behaviour. Leaves nothing behind.
set -euo pipefail
cd "$(dirname "$0")"

clean() { rm -rf ./*/.terraform ./*/terraform.tfstate* ./*/.terraform.lock.hcl ./*/out ./*/users; }
trap clean EXIT
q() { terraform "$@" -no-color > /dev/null; }

echo "######## Lab 1a — count: remove bob from the middle"
cd lab1-count-vs-foreach
cp main.tf /tmp/foreach.tf && cp count.tf.example main.tf
q init -input=false && q apply -auto-approve
terraform plan -no-color -var 'users=["alice","carol"]' | grep -E "must be replaced|will be destroyed|Plan:"
q destroy -auto-approve
rm -f terraform.tfstate*
echo "######## Lab 1b — for_each: remove bob"
cp /tmp/foreach.tf main.tf
q apply -auto-approve
terraform plan -no-color -var 'users={alice={team="platform",admin=true},carol={team="platform",admin=false}}' | grep -E "must be replaced|will be destroyed|Plan:"
q destroy -auto-approve
cd ..

echo "######## Lab 2 — inventory generator"
cd lab2-inventory
q init -input=false && q apply -auto-approve
cat out/inventory.ini out/upstream.conf
terraform output -json ip_by_name
q destroy -auto-approve
cd ..

echo "######## Lab 3 — conditionals"
cd lab3-conditionals
q init -input=false
for env in dev prod; do
    q apply -auto-approve -var "environment=$env"
    echo "$env: $(terraform output -json | jq -c '{vpc: .vpc_cidr.value, subnets: .subnets.value, monitoring: .monitoring_enabled.value}')"
done
q destroy -auto-approve -var environment=prod
cd ..

echo "######## Lab 4 — dynamic blocks (validate only)"
cd lab4-dynamic
q init -input=false
terraform validate -no-color
cd ..
echo "🎉 done"
