"""largest_files.py PATH [-n N] — the N largest files under PATH (one file system, no symlinks), human-readable.

The answer to "the disk is full, what's using it?" when ncdu isn't installed.
"""
import argparse
import heapq
import os


def human(size):
    for unit in ("B", "K", "M", "G", "T"):
        if size < 1024 or unit == "T":
            return f"{size:.0f}{unit}" if unit == "B" else f"{size:.1f}{unit}"
        size /= 1024


def largest(path, n=10):
    root_dev = os.stat(path).st_dev
    files = []
    for dirpath, dirnames, filenames in os.walk(path):
        # stay on this file system (like du -x / find -xdev)
        dirnames[:] = [d for d in dirnames if os.lstat(os.path.join(dirpath, d)).st_dev == root_dev]
        for name in filenames:
            full = os.path.join(dirpath, name)
            try:
                st = os.lstat(full)
            except OSError:                    # vanished or unreadable: skip, don't crash
                continue
            if os.path.islink(full):
                continue
            files.append((st.st_size, full))
    return heapq.nlargest(n, files)            # O(files · log n), no full sort


def main(argv=None):
    p = argparse.ArgumentParser(description="largest files under a path")
    p.add_argument("path")
    p.add_argument("-n", type=int, default=10)
    args = p.parse_args(argv)
    for size, name in largest(args.path, args.n):
        print(f"{human(size):>8}  {name}")


if __name__ == "__main__":
    main()
