#!/usr/bin/env python3
"""Move files into sub-folders by type. Usage: organise.py FOLDER [--dry-run]"""
import argparse
import shutil
import sys
from pathlib import Path

CATEGORIES = {
    "logs": {".log"},
    "configs": {".yml", ".yaml", ".conf", ".ini", ".toml", ".json"},
    "scripts": {".sh", ".py"},
}


def category_for(path: Path) -> str:
    for name, extensions in CATEGORIES.items():
        if path.suffix.lower() in extensions:
            return name
    return "other"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not args.folder.is_dir():
        print(f"ERROR: {args.folder} is not a directory", file=sys.stderr)
        return 1

    for item in sorted(args.folder.iterdir()):
        if not item.is_file():
            continue
        target_dir = args.folder / category_for(item)
        print(f"{'[dry-run] ' if args.dry_run else ''}{item.name} -> {target_dir.name}/")
        if not args.dry_run:
            target_dir.mkdir(exist_ok=True)
            shutil.move(str(item), target_dir / item.name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
