#!/usr/bin/env python3
from dataclasses import dataclass, field

ENV_ORDER = {"dev": 0, "staging": 1, "prod": 2}


class DeploymentError(Exception):
    """Raised when a deployment violates a rule."""


@dataclass
class Deployment:
    app: str
    version: str
    env: str
    replicas: int = 1


@dataclass
class Pipeline:
    deployments: list[Deployment] = field(default_factory=list)
    history: list[str] = field(default_factory=list)

    def add(self, deployment: Deployment) -> None:
        self.deployments.append(deployment)

    def run(self, dry_run: bool = True) -> None:
        mode = "DRY-RUN" if dry_run else "LIVE"
        for d in sorted(self.deployments, key=lambda d: ENV_ORDER[d.env]):
            if d.env == "prod" and d.replicas < 2:
                raise DeploymentError(f"{d.app} in prod needs >= 2 replicas, got {d.replicas}")
            msg = f"[{mode}] {d.app}:{d.version} -> {d.env} x{d.replicas}"
            print(msg)
            self.history.append(msg)


if __name__ == "__main__":
    pipeline = Pipeline()
    pipeline.add(Deployment("api", "2.0.0", "prod", replicas=3))
    pipeline.add(Deployment("api", "2.0.0", "dev"))
    pipeline.add(Deployment("api", "2.0.0", "staging", replicas=2))
    pipeline.run()

    bad = Pipeline()
    bad.add(Deployment("web", "1.0.0", "prod", replicas=1))
    try:
        bad.run()
    except DeploymentError as e:
        print("Blocked:", e)

    print("History:", *pipeline.history, sep="\n  ")
