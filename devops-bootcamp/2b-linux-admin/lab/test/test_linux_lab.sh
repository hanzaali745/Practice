#!/usr/bin/env bash
# test_linux_lab.sh — MAINTAINER test: prove the labs, checkers, capstone and cleanup work together.
# For each module: check FAILS on a fresh server → reference solution → check PASSES. Then the capstone's
# provision.sh twice on a new server (idempotent) → check all; then cleanup.sh → lab users are gone.
# Uses a privileged systemd container as a stand-in for the lab VM (learners use a real VM).
set -uo pipefail
cd "$(dirname "$0")" || exit 2
course=$(cd ../.. && pwd)
image=linux-admin-test:24.04
name=linux-lab-test
failed=0

docker build -q -t "$image" . > /dev/null || exit 1
start() {
    docker rm -f "$name" > /dev/null 2>&1
    docker run -d --name "$name" --hostname lab-server --privileged --cgroupns=host \
        -v /sys/fs/cgroup:/sys/fs/cgroup:rw --tmpfs /run --tmpfs /run/lock --tmpfs /tmp \
        -v "$course:/opt/course:ro" "$image" > /dev/null
    for _ in $(seq 1 30); do
        [[ $(docker exec "$name" systemctl is-system-running 2> /dev/null) =~ running|degraded ]] && return 0
        sleep 1
    done
}
inside() { docker exec "$name" "$@"; }
stop() {   # detach loop devices first: they live in the host kernel, not in the container
    inside /opt/course/lab/cleanup.sh > /dev/null 2>&1
    docker rm -f "$name" > /dev/null 2>&1
}
trap stop EXIT

start
for m in 01 02 03 04 05 06 07 08; do
    dir=$(cd "$course" && ls -d "$m"-*)
    printf '%-32s' "$dir"
    if inside /opt/course/lab/check.sh "$m" > /dev/null 2>&1; then echo "❌ check passes before the lab"; failed=1; continue; fi
    if ! out=$(inside "/opt/course/$dir/solutions/labs.sh" 2>&1); then
        echo "❌ solution failed"; tail -5 <<< "$out" | sed 's/^/    /'; failed=1; continue
    fi
    sleep 2                                                     # let the heartbeat log a line
    if out=$(inside /opt/course/lab/check.sh "$m" 2>&1); then
        echo "✅$(grep -q '⏭️' <<< "$out" && echo "  (some checks skipped here: $(grep -c '⏭️' <<< "$out"))")"
    else
        echo "❌ check fails after the solution"; grep -E '❌|⏭️' <<< "$out" | sed 's/^/    /'; failed=1
    fi
done
stop

printf '%-32s' "capstone: provision ×2 + check all"
start
if inside /opt/course/09-capstone/solutions/provision.sh > /dev/null 2>&1 &&
   inside /opt/course/09-capstone/solutions/provision.sh > /dev/null 2>&1 && sleep 2 &&
   inside /opt/course/lab/check.sh all > /dev/null 2>&1; then echo "✅"; else
    echo "❌"; inside /opt/course/lab/check.sh all 2>&1 | grep '❌' | sed 's/^/    /'; failed=1
fi

printf '%-32s' "cleanup.sh removes the lab state"
inside /opt/course/lab/cleanup.sh > /dev/null 2>&1
if ! inside id alice > /dev/null 2>&1 && ! inside test -e /srv/devteam && ! losetup -a | grep lab-disks > /dev/null &&
   ! inside /opt/course/lab/check.sh 02 > /dev/null 2>&1; then echo "✅"; else echo "❌"; failed=1; fi
exit $failed
