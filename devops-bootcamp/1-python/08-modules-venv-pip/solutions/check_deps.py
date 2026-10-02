#!/usr/bin/env python3
"""Lab 3: confirm third-party packages are installed in the active venv."""
import sys

try:
    import requests
    import yaml
except ImportError as e:
    print(f"Missing dependency: {e.name}. Run: pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

print("python  ", sys.executable)
print("requests", requests.__version__)
print("pyyaml  ", yaml.__version__)
