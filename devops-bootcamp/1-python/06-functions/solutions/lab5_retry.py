#!/usr/bin/env python3
import time


def retry(func, attempts: int = 3, delay: float = 0.1) -> bool:
    """Call func() until it returns True or attempts run out."""
    for attempt in range(1, attempts + 1):
        if func():
            print(f"succeeded on attempt {attempt}")
            return True
        print(f"attempt {attempt} failed")
        if attempt < attempts:
            time.sleep(delay)
    return False


def main() -> None:
    calls = {"count": 0}

    def flaky_service() -> bool:
        calls["count"] += 1
        return calls["count"] >= 3

    print("Result:", retry(flaky_service, attempts=5))
    calls["count"] = 0
    print("Result:", retry(flaky_service, attempts=2))


if __name__ == "__main__":
    main()
