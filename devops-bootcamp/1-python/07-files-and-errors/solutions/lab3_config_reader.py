#!/usr/bin/env python3
import sys


def read_config(path: str) -> dict[str, str]:
    """Read key=value lines into a dict. Ignores blanks and # comments."""
    config: dict[str, str] = {}
    try:
        with open(path, encoding="utf-8") as f:
            for line_no, raw in enumerate(f, start=1):
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" not in line:
                    raise ValueError(f"{path}:{line_no}: expected key=value, got {line!r}")
                key, value = line.split("=", 1)
                config[key.strip()] = value.strip()
    except FileNotFoundError:
        print(f"WARNING: {path} not found, using empty config", file=sys.stderr)
        return {}
    return config


if __name__ == "__main__":
    with open("demo.conf", "w", encoding="utf-8") as f:
        f.write("# demo config\nAPP=api\n\nPORT = 8080\nDEBUG=false\n")
    print(read_config("demo.conf"))
    print(read_config("missing.conf"))
