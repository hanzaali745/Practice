#!/usr/bin/env bash
# test_lab.sh [SCENARIO...] — prove every scenario works: break → check FAILS → reference fix → check PASSES
# The reference fixes live in the modules' solutions/fixes/ folders. Takes ~10 s per scenario.
set -uo pipefail
cd "$(dirname "$0")" || exit 2
fix_for() { local f; for f in ../0*/solutions/fixes/"$1".sh; do [[ -f $f ]] && echo "$f"; done; }
if (( $# )); then names=("$@"); else names=(); for d in scenarios/*/; do names+=("$(basename "$d")"); done; fi
failed=0
for name in "${names[@]}"; do
    printf '%-18s' "$name"
    ./lab.sh break "$name" > /dev/null || { echo "❌ break failed"; failed=1; continue; }
    if ./lab.sh check > /dev/null 2>&1; then echo "❌ check passes while broken"; failed=1; continue; fi
    parts=("$name"); [[ -f scenarios/$name/combo ]] && mapfile -t parts < "scenarios/$name/combo"
    for part in "${parts[@]}"; do
        fix=$(fix_for "$part")
        [[ -n $fix ]] || { echo "❌ no reference fix for $part"; failed=1; continue 2; }
        docker compose exec -T server bash -s < "$fix" > /dev/null 2>&1
    done
    if out=$(./lab.sh check 2>&1); then echo "✅"; else echo "❌ still broken after the reference fix"; echo "$out" | grep "❌" | sed 's/^/    /'; failed=1; fi
done
./lab.sh down > /dev/null 2>&1
exit $failed
