#!/usr/bin/env python3
"""Lab 4 — scan YOUR OWN host three ways and compare speed.

Usage: portscan.py HOST [--ports 1-1024] [--mode seq|threads|async|all] [--timeout 0.5]
"""
import argparse
import asyncio
import socket
import sys
import time
from concurrent.futures import ThreadPoolExecutor


def parse_ports(spec: str) -> list[int]:
    """'22,80,8000-8002' -> [22, 80, 8000, 8001, 8002]"""
    ports: list[int] = []
    for part in spec.split(","):
        if "-" in part:
            lo, hi = (int(x) for x in part.split("-", 1))
            ports.extend(range(lo, hi + 1))
        else:
            ports.append(int(part))
    if not all(1 <= p <= 65535 for p in ports):
        raise ValueError("ports must be between 1 and 65535")
    return ports


def check(host: str, port: int, timeout: float) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def scan_seq(host: str, ports: list[int], timeout: float) -> list[int]:
    return [p for p in ports if check(host, p, timeout)]


def scan_threads(host: str, ports: list[int], timeout: float, workers: int = 100) -> list[int]:
    with ThreadPoolExecutor(max_workers=workers) as pool:
        results = pool.map(lambda p: (p, check(host, p, timeout)), ports)
        return [p for p, ok in results if ok]


async def _check_async(host: str, port: int, timeout: float, sem: asyncio.Semaphore) -> bool:
    async with sem:                       # limit how many connections are open at once
        try:
            _, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
        except (OSError, asyncio.TimeoutError):
            return False
        writer.close()
        await writer.wait_closed()
        return True


async def _scan_async(host: str, ports: list[int], timeout: float) -> list[int]:
    sem = asyncio.Semaphore(200)
    results = await asyncio.gather(*(_check_async(host, p, timeout, sem) for p in ports))
    return [p for p, ok in zip(ports, results, strict=True) if ok]


def scan_async(host: str, ports: list[int], timeout: float) -> list[int]:
    return asyncio.run(_scan_async(host, ports, timeout))


MODES = {"seq": scan_seq, "threads": scan_threads, "async": scan_async}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("host")
    parser.add_argument("--ports", default="1-1024")
    parser.add_argument("--mode", choices=[*MODES, "all"], default="all")
    parser.add_argument("--timeout", type=float, default=0.5)
    args = parser.parse_args(argv)

    try:
        ports = parse_ports(args.ports)
    except ValueError as e:
        parser.error(str(e))

    modes = list(MODES) if args.mode == "all" else [args.mode]
    for mode in modes:
        start = time.perf_counter()
        open_ports = MODES[mode](args.host, ports, args.timeout)
        print(f"{mode:<8} {time.perf_counter() - start:6.2f}s  open: {open_ports or 'none'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
