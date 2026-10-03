"""retry.py — retry a flaky call properly: only retryable errors, exponential backoff with jitter, a limit.

    @retry(attempts=5, base=0.5, retry_on=(TimeoutError, ConnectionError))
    def get_token(): ...
"""
import functools
import logging
import random
import time

log = logging.getLogger(__name__)


def retry(attempts=5, base=0.5, cap=30.0, retry_on=(Exception,), sleep=time.sleep):
    """Retry the decorated function on the given exceptions.

    Delay before retry k (k = 1, 2, ...) is random between 0 and min(cap, base * 2**(k-1)) — "full jitter", so many
    clients retrying at once don't hit the server in synchronised waves. The last error is re-raised.
    """
    if attempts < 1:
        raise ValueError("attempts must be >= 1")

    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, attempts + 1):
                try:
                    return func(*args, **kwargs)
                except retry_on as e:
                    if attempt == attempts:
                        raise
                    delay = random.uniform(0, min(cap, base * 2 ** (attempt - 1)))
                    log.warning("%s failed (%s), retry %d/%d in %.2fs", func.__name__, e, attempt, attempts - 1, delay)
                    sleep(delay)
        return wrapper
    return decorator
