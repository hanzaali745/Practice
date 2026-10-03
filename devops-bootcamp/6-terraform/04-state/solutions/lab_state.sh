#!/usr/bin/env bash
# Run and check all Module 04 labs. Leaves nothing behind.
set -euo pipefail
cd "$(dirname "$0")"

clean() { rm -rf ./*/.terraform ./*/terraform.tfstate* ./*/.terraform.lock.hcl ./*/out ./*/app-*.txt; }
trap clean EXIT
q() { terraform "$@" -no-color > /dev/null; }

echo "######## Lab 1 — explore"
cd lab1-explore
q init -input=false && q apply -auto-approve
terraform state list
echo "random value: $(terraform show -json | jq -r '.values.root_module.resources[] | select(.address=="random_string.suffix") | .values.result')"
rm -f app-*.txt
echo "-- drift check after deleting the file by hand:"
terraform plan -refresh-only -no-color | grep -E "has been deleted|changed outside" | head -2
cd ..

echo "######## Lab 2 — moved"
cp lab2-moved/main.tf /tmp/lab2-main.tf.orig
cd lab2-moved && q init -input=false && q apply -auto-approve && ./rename.sh && cd ..
cp /tmp/lab2-main.tf.orig lab2-moved/main.tf

echo "######## Lab 3 — import + removed"
cp lab3-import-remove/main.tf /tmp/lab3-main.tf.orig
cd lab3-import-remove
q init -input=false
terraform plan -no-color | grep -E "will be imported|Plan:"
q apply -auto-approve
echo "imported value: $(terraform state show -no-color random_string.legacy | awk '/result/ {print $3}')"
./forget.sh
cd ..
cp /tmp/lab3-main.tf.orig lab3-import-remove/main.tf

echo "######## Lab 4 — workspaces"
cd lab4-workspaces
q init -input=false
for ws in dev prod; do
    terraform workspace new "$ws" > /dev/null
    q apply -auto-approve
done
terraform workspace list
ls out/ terraform.tfstate.d/
for ws in prod dev; do terraform workspace select "$ws" > /dev/null; q destroy -auto-approve; done
terraform workspace select default > /dev/null
cd ..
echo "🎉 all state labs ran"
