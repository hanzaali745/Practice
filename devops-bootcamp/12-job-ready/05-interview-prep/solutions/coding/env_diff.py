"""env_diff.py A.env B.env — what differs between two KEY=VALUE config files (e.g. staging vs production)?

Shows added, removed and changed keys. Values of keys that look secret are masked, so the output is safe to paste in a
ticket. Exit 1 if there are differences.
"""
import re
import sys

SECRET = re.compile(r"(PASS|SECRET|TOKEN|KEY|CREDENTIAL)", re.IGNORECASE)


def parse(text):
    values = {}
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export "):]
        if "=" not in line:
            raise ValueError(f"line {n}: expected KEY=VALUE, got {raw!r}")
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip('"').strip("'")
    return values


def show(key, value):
    return "****" if SECRET.search(key) else value


def diff(a, b):
    lines = []
    for key in sorted(a.keys() | b.keys()):
        if key not in b:
            lines.append(f"- {key}={show(key, a[key])}")
        elif key not in a:
            lines.append(f"+ {key}={show(key, b[key])}")
        elif a[key] != b[key]:
            lines.append(f"~ {key}: {show(key, a[key])} → {show(key, b[key])}")
    return lines


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) != 2:
        sys.exit(__doc__)
    with open(argv[0]) as fa, open(argv[1]) as fb:
        lines = diff(parse(fa.read()), parse(fb.read()))
    print("\n".join(lines) if lines else "identical")
    return 1 if lines else 0


if __name__ == "__main__":
    sys.exit(main())
