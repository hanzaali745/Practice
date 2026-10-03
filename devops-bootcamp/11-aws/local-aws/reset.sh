#!/usr/bin/env bash
# reset.sh — wipe everything in the local fake AWS (like a brand-new account)
set -euo pipefail
curl -fsS -X POST http://localhost:5000/moto-api/reset > /dev/null && echo "local AWS reset"
