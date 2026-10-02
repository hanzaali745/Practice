#!/usr/bin/env python3
"""Lab 2: use the devopskit package. Run from this folder: python3 main.py"""
import devopskit
from devopskit.checks import is_port_open
from devopskit.convert import bytes_to_human


def main() -> None:
    print(f"devopskit v{devopskit.__version__}")
    print("10 GB looks like:", bytes_to_human(10 * 1024**3))
    for port in (22, 80, 443):
        state = "open" if is_port_open("localhost", port, timeout=0.5) else "closed"
        print(f"localhost:{port} is {state}")


if __name__ == "__main__":
    main()
