"""Small, testable ops helpers used by the Module 13 labs."""
import subprocess
from pathlib import Path


def is_valid_port(port: object) -> bool:
    """Return True if port is an int between 1 and 65535."""
    return isinstance(port, int) and not isinstance(port, bool) and 1 <= port <= 65535


def is_valid_ipv4(ip: str) -> bool:
    """Return True if ip is a dotted-quad IPv4 address."""
    parts = ip.split(".")
    return len(parts) == 4 and all(p.isdigit() and 0 <= int(p) <= 255 for p in parts)


def count_levels(path: Path) -> dict[str, int]:
    """Count log lines by their first word (the level)."""
    counts: dict[str, int] = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            words = line.split()
            if words:
                counts[words[0]] = counts.get(words[0], 0) + 1
    return counts


def service_is_active(name: str) -> bool:
    """Return True if `systemctl is-active NAME` reports 'active'."""
    result = subprocess.run(
        ["systemctl", "is-active", name], capture_output=True, text=True, timeout=10
    )
    return result.returncode == 0 and result.stdout.strip() == "active"
