"""Lab 2 — @timed and @retry decorators."""
import functools
import time
from collections.abc import Callable
from typing import Any


def timed(func: Callable[..., Any]) -> Callable[..., Any]:
    """Print how long each call takes."""
    @functools.wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            print(f"{func.__name__} took {time.perf_counter() - start:.3f}s")
    return wrapper


def retry(times: int = 3, delay: float = 1.0, exceptions: tuple[type[BaseException], ...] = (Exception,)):
    """Retry the function on the given exceptions, with exponential backoff."""
    if times < 1:
        raise ValueError("times must be >= 1")

    def decorator(func: Callable[..., Any]) -> Callable[..., Any]:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            for attempt in range(1, times + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == times:
                        raise
                    wait = delay * 2 ** (attempt - 1)
                    print(f"{func.__name__} failed ({e!r}); retry {attempt}/{times - 1} in {wait:.2f}s")
                    time.sleep(wait)
            raise AssertionError("unreachable")
        return wrapper
    return decorator


if __name__ == "__main__":
    calls = {"n": 0}

    @timed
    @retry(times=5, delay=0.1, exceptions=(ConnectionError,))
    def flaky() -> str:
        """Fails twice, then works."""
        calls["n"] += 1
        if calls["n"] < 3:
            raise ConnectionError("connection refused")
        return "ok"

    print(flaky(), "| name kept:", flaky.__name__, "| doc kept:", flaky.__doc__)
