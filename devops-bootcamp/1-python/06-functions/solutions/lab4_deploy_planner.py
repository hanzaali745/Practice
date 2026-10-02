#!/usr/bin/env python3
def plan_deploy(app: str, *envs: str, dry_run: bool = False, **options) -> None:
    mode = "DRY-RUN" if dry_run else "LIVE"
    opts = ", ".join(f"{k}={v}" for k, v in options.items()) or "no options"
    for step, env in enumerate(envs, start=1):
        print(f"[{mode}] step {step}: deploy {app} -> {env} ({opts})")


if __name__ == "__main__":
    plan_deploy("api", "staging", "prod", dry_run=True, version="1.2.0", replicas=3)
