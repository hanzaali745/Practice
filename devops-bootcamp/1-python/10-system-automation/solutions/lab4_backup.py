#!/usr/bin/env python3
"""Create timestamped .tar.gz backups and keep only the newest N.

Usage: backup.py SOURCE DEST [--keep 5] [-v]
"""
import argparse
import logging
import sys
import tarfile
from datetime import datetime
from pathlib import Path

log = logging.getLogger("backup")


def create_backup(source: Path, dest: Path) -> Path:
    dest.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    archive = dest / f"{source.name}-{stamp}.tar.gz"
    log.debug("Archiving %s -> %s", source, archive)
    with tarfile.open(archive, "w:gz") as tar:
        tar.add(source, arcname=source.name)
    log.info("Created %s (%.1f KB)", archive, archive.stat().st_size / 1024)
    return archive


def rotate(dest: Path, prefix: str, keep: int) -> None:
    backups = sorted(dest.glob(f"{prefix}-*.tar.gz"), key=lambda p: p.stat().st_mtime, reverse=True)
    for old in backups[keep:]:
        log.info("Removing old backup %s", old)
        old.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", type=Path)
    parser.add_argument("dest", type=Path)
    parser.add_argument("--keep", type=int, default=5)
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)-7s %(message)s",
    )

    if not args.source.exists():
        log.error("Source %s does not exist", args.source)
        return 1

    create_backup(args.source, args.dest)
    rotate(args.dest, args.source.name, args.keep)
    return 0


if __name__ == "__main__":
    sys.exit(main())
