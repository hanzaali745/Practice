"""structured_logging.py — JSON logs from Python's standard logging module, with a request id on every line.

Run it:  python3 structured_logging.py | jq .
"""
import contextvars
import json
import logging
import sys
import uuid
from datetime import datetime, timezone

request_id: contextvars.ContextVar[str] = contextvars.ContextVar("request_id", default="-")


class JsonFormatter(logging.Formatter):
    """Turn a LogRecord into one JSON line with ECS-style field names."""

    def format(self, record: logging.LogRecord) -> str:
        doc = {
            "@timestamp": datetime.fromtimestamp(record.created, timezone.utc).isoformat(timespec="milliseconds"),
            "log": {"level": record.levelname.lower(), "logger": record.name},
            "message": record.getMessage(),
            "trace": {"id": request_id.get()},          # correlation id: find every line of one request
            **getattr(record, "fields", {}),            # extra structured fields passed with extra={"fields": ...}
        }
        if record.exc_info:
            doc["error"] = {"type": record.exc_info[0].__name__, "stack_trace": self.formatException(record.exc_info)}
        return json.dumps(doc)


def setup() -> logging.Logger:
    handler = logging.StreamHandler(sys.stdout)       # containers: log to stdout, let the platform collect it
    handler.setFormatter(JsonFormatter())
    logging.basicConfig(level=logging.INFO, handlers=[handler])
    return logging.getLogger("orders")


def handle_order(log: logging.Logger, order_id: int, amount: float) -> None:
    request_id.set(uuid.uuid4().hex[:12])              # one id per request
    log.info("order received", extra={"fields": {"order": {"id": order_id, "amount": amount}}})
    try:
        if amount <= 0:
            raise ValueError("amount must be positive")
        log.info("order stored", extra={"fields": {"order": {"id": order_id}}})
    except ValueError:
        log.exception("order rejected", extra={"fields": {"order": {"id": order_id}}})


if __name__ == "__main__":
    logger = setup()
    handle_order(logger, 1001, 49.90)
    handle_order(logger, 1002, -5)
    logger.debug("this is hidden: level is INFO")
