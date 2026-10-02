#!/usr/bin/env bash
# Lab 4 — read Terraform outputs from a script (how pipelines hand results to the next step)
set -euo pipefail
cd "$(dirname "$0")"

json=$(terraform output -json summary)
env=$(jq -r .environment <<< "$json")
replicas=$(jq -r .replicas <<< "$json")
port=$(jq -r .port <<< "$json")
echo "Environment $env runs $replicas replica(s) on port $port"
