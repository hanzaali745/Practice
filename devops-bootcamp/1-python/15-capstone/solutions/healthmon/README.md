# healthmon

Check HTTP endpoints, TCP ports and disk usage defined in a YAML file.

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt pytest
./healthmon.py targets.yaml
./healthmon.py targets.yaml --json -v
pytest -v
```

Exit codes: `0` all OK · `1` a check failed · `2` bad config.
