#!/usr/bin/env python3
def is_valid_port(port) -> bool:
    """Return True if port is an int between 1 and 65535."""
    return isinstance(port, int) and 1 <= port <= 65535


def is_valid_ipv4(ip: str) -> bool:
    """Return True if ip is a dotted IPv4 address like 10.0.0.1."""
    parts = ip.split(".")
    if len(parts) != 4:
        return False
    for part in parts:
        if not part.isdigit() or not 0 <= int(part) <= 255:
            return False
    return True


if __name__ == "__main__":
    for ip in ["192.168.1.1", "256.1.1.1", "10.0.0", "a.b.c.d"]:
        print(f"{ip:<12} valid={is_valid_ipv4(ip)}")
    for port in [22, 0, 70000, "80"]:
        print(f"{port!r:<6} valid={is_valid_port(port)}")
