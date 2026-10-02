"""Command-line entry point: `devopskit <subcommand> ...`"""
import argparse
import socket
import sys
from concurrent.futures import ThreadPoolExecutor

from devopskit import __version__


def bytes_to_human(n: float) -> str:
    size = float(n)
    for unit in ["B", "KB", "MB", "GB"]:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"


def _is_open(host: str, port: int, timeout: float) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def cmd_ports(args: argparse.Namespace) -> int:
    lo, _, hi = args.range.partition("-")
    ports = range(int(lo), int(hi or lo) + 1)
    with ThreadPoolExecutor(max_workers=100) as pool:
        states = pool.map(lambda p: (p, _is_open(args.host, p, args.timeout)), ports)
        open_ports = [p for p, ok in states if ok]
    print(f"{args.host}: open ports {open_ports or 'none'}")
    return 0


def cmd_bytes(args: argparse.Namespace) -> int:
    for value in args.values:
        print(f"{value} -> {bytes_to_human(value)}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="devopskit", description="Small DevOps helpers")
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    sub = parser.add_subparsers(dest="command", required=True)

    p_ports = sub.add_parser("ports", help="scan TCP ports on a host you own")
    p_ports.add_argument("host")
    p_ports.add_argument("--range", default="1-1024", help="e.g. 1-1024 or 8000")
    p_ports.add_argument("--timeout", type=float, default=0.5)
    p_ports.set_defaults(func=cmd_ports)

    p_bytes = sub.add_parser("bytes", help="convert byte counts to human-readable")
    p_bytes.add_argument("values", type=int, nargs="+")
    p_bytes.set_defaults(func=cmd_bytes)

    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
