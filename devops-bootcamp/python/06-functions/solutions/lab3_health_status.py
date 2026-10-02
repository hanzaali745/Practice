#!/usr/bin/env python3
def health_status(cpu: float, mem: float, disk: float, threshold: float = 80) -> tuple[str, list[str]]:
    """Return ("OK" | "DEGRADED", [metrics above threshold])."""
    metrics = {"cpu": cpu, "mem": mem, "disk": disk}
    problems = [name for name, value in metrics.items() if value > threshold]
    status = "DEGRADED" if problems else "OK"
    return status, problems


if __name__ == "__main__":
    print(health_status(50, 60, 70))
    print(health_status(95, 60, 85))
    print(health_status(95, 60, 85, threshold=90))
