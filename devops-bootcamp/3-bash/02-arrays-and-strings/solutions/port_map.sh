#!/usr/bin/env bash
# Lab 2 — associative array: service -> port
declare -A ports=(
    [nginx]=80
    [https]=443
    [ssh]=22
    [postgres]=5432
    [redis]=6379
    [grafana]=3000
)

printf "%-10s %s\n" "SERVICE" "PORT"
while IFS= read -r svc; do
    printf "%-10s %s\n" "$svc" "${ports[$svc]}"
done < <(printf '%s\n' "${!ports[@]}" | sort)

echo
for wanted in 22 3306 8080; do
    found=""
    for svc in "${!ports[@]}"; do
        [[ ${ports[$svc]} == "$wanted" ]] && found="$svc"
    done
    echo "port $wanted -> ${found:-unknown}"
done
