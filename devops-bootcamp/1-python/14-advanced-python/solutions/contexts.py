"""Lab 3 — custom context managers."""
import contextlib
import fcntl
import os
import time
from collections.abc import Iterator


@contextlib.contextmanager
def timer(label: str) -> Iterator[None]:
    start = time.perf_counter()
    try:
        yield
    finally:
        print(f"{label}: {time.perf_counter() - start:.3f}s")


@contextlib.contextmanager
def working_directory(path: str) -> Iterator[str]:
    old = os.getcwd()
    os.chdir(path)
    try:
        yield path
    finally:
        os.chdir(old)


@contextlib.contextmanager
def file_lock(path: str) -> Iterator[None]:
    """Hold an exclusive lock on `path`; raise RuntimeError if another process has it."""
    with open(path, "w") as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as e:
            raise RuntimeError(f"already running (lock {path} is held)") from e
        try:
            yield
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)


if __name__ == "__main__":
    import sys

    with timer("demo"), working_directory("/tmp"):
        print("inside:", os.getcwd())
    print("back in:", os.getcwd())

    # Run this file twice at once to see the lock:  python3 contexts.py & python3 contexts.py
    try:
        with file_lock("/tmp/contexts-demo.lock"):
            print("lock acquired, working 2s...")
            time.sleep(2)
    except RuntimeError as e:
        print("ERROR:", e, file=sys.stderr)
        sys.exit(1)
