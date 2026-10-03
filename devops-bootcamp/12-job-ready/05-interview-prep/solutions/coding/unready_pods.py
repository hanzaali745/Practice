"""unready_pods.py — which Pods are not ready, and why?   kubectl get pods -A -o json | python3 unready_pods.py

Prints namespace/name, phase, and the most useful reason per container (CrashLoopBackOff, ImagePullBackOff,
OOMKilled, ...). Exit 1 if any Pod is unready — usable in scripts and CI smoke tests.
"""
import json
import sys


def reasons(pod):
    out = []
    for cs in pod.get("status", {}).get("containerStatuses", []):
        if cs.get("ready"):
            continue
        state = cs.get("state", {})
        last = cs.get("lastState", {}).get("terminated", {})
        if "waiting" in state:
            why = state["waiting"].get("reason", "Waiting")
        elif "terminated" in state:
            why = state["terminated"].get("reason", "Terminated")
        else:
            why = "NotReady"                        # running, but the readiness probe fails
        if last.get("reason"):
            why += f" (last: {last['reason']}, exit {last.get('exitCode')})"
        out.append(f"{cs['name']}: {why} restarts={cs.get('restartCount', 0)}")
    if not out:                                      # e.g. Pending: no containers yet — look at the conditions
        for cond in pod.get("status", {}).get("conditions", []):
            if cond.get("status") == "False" and cond.get("reason"):
                out.append(f"{cond['type']}: {cond['reason']} {cond.get('message', '')}".strip())
    return out


def unready(pods_json):
    result = []
    for pod in pods_json.get("items", []):
        phase = pod.get("status", {}).get("phase")
        if phase == "Succeeded":                     # finished Jobs are fine
            continue
        conditions = {c["type"]: c["status"] for c in pod.get("status", {}).get("conditions", [])}
        if conditions.get("Ready") == "True":
            continue
        meta = pod["metadata"]
        result.append((f"{meta.get('namespace', 'default')}/{meta['name']}", phase, reasons(pod)))
    return result


def main():
    bad = unready(json.load(sys.stdin))
    for name, phase, why in bad:
        print(f"❌ {name} [{phase}]")
        for line in why:
            print(f"     {line}")
    if not bad:
        print("✅ all Pods ready")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
