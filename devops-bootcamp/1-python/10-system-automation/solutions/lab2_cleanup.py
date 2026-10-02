#!/usr/bin/env python3
"""Delete files older than N days. Usage: cleanup.py FOLDER --days N [--pattern GLOB] [--dry-run]"""
import argparse
import logging
import sys
import time
from pathlib import Path

log = logging.getLogger("cleanup")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--days", type=int, required=True)
    parser.add_argument("--pattern", default="*")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    if not args.folder.is_dir():
        log.error("%s is not a directory", args.folder)
        return 1

    cutoff = time.time() - args.days * 86400
    freed = 0
    for path in args.folder.rglob(args.pattern):
        if path.is_file() and path.stat().st_mtime < cutoff:
            size = path.stat().st_size
            log.info("%sdeleting %s (%d bytes)", "[dry-run] " if args.dry_run else "", path, size)
            if not args.dry_run:
                path.unlink()
            freed += size
    log.info("Total %s: %.1f KB", "to free" if args.dry_run else "freed", freed / 1024)
    return 0


if __name__ == "__main__":
    sys.exit(main())
