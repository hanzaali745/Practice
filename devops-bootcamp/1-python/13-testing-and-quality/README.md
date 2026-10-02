# Python Module 13 — Testing & Code Quality 🔴

## 🎯 Objectives
- Write unit tests with **pytest**
- Use fixtures, `tmp_path`, `parametrize`, and `monkeypatch`
- Mock external things (commands, APIs) so tests are fast and safe
- Use type hints + `mypy`, and lint/format with `ruff`
- Run all of it automatically in **CI (GitHub Actions)**

## 🧠 Why DevOps engineers care
Your automation touches **production**. A bug in a cleanup script can delete the wrong
data; a bug in a deploy script can take a site down. Tests are your safety net, and
CI runs them on every commit. "Shift left" = catch problems before they reach prod.

---

## 📖 Lesson 13.1 — First test with pytest

```bash
pip install pytest
```
> 🐧 **Ubuntu:** run `pip` only inside your venv (`source ~/venvs/devops/bin/activate`). If you did Step 0, this is already installed.

`calc.py`:
```python
def disk_percent(used: float, total: float) -> float:
    if total <= 0:
        raise ValueError("total must be positive")
    return round(used / total * 100, 1)
```

`test_calc.py` (files and functions must start with `test_`):
```python
import pytest
from calc import disk_percent

def test_disk_percent():
    assert disk_percent(375, 500) == 75.0

def test_disk_percent_rejects_zero_total():
    with pytest.raises(ValueError):
        disk_percent(1, 0)
```

```bash
pytest -v            # run all tests
pytest -k percent    # only tests matching a name
pytest -x            # stop on first failure
```

## 📖 Lesson 13.2 — Parametrize (many cases, one test)

```python
@pytest.mark.parametrize("used,total,expected", [
    (0, 100, 0.0),
    (50, 100, 50.0),
    (1, 3, 33.3),
])
def test_disk_percent_cases(used, total, expected):
    assert disk_percent(used, total) == expected
```

## 📖 Lesson 13.3 — Fixtures & temporary files

```python
@pytest.fixture
def sample_log(tmp_path):          # tmp_path = a fresh temp dir per test (built-in fixture)
    log = tmp_path / "app.log"
    log.write_text("INFO ok\nERROR boom\nERROR bang\n")
    return log

def test_count_errors(sample_log):
    assert count_errors(sample_log) == 2
```

## 📖 Lesson 13.4 — monkeypatch & mocks

Never call real APIs or run dangerous commands in unit tests. Replace them:

```python
def test_reads_env(monkeypatch):
    monkeypatch.setenv("APP_PORT", "9090")
    assert get_port() == 9090

from unittest.mock import patch, MagicMock

def test_service_active():
    fake = MagicMock(returncode=0, stdout="active\n")
    with patch("svc.subprocess.run", return_value=fake) as run:
        assert is_active("nginx") is True
        run.assert_called_once()
```

## 📖 Lesson 13.5 — Type hints + mypy

```python
def restart(services: list[str], dry_run: bool = False) -> dict[str, bool]: ...
```

```bash
pip install mypy
mypy myscript.py          # finds type bugs WITHOUT running the code
```

## 📖 Lesson 13.6 — Lint & format with ruff

```bash
pip install ruff
ruff check .              # find bugs & style issues (unused imports, etc.)
ruff check . --fix        # auto-fix
ruff format .             # consistent formatting (like black)
```

## 📖 Lesson 13.7 — CI with GitHub Actions

`.github/workflows/python-ci.yml`:
```yaml
name: python-ci
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt pytest ruff mypy
      - run: ruff check .
      - run: mypy .
      - run: pytest -v
```

Now every push is automatically linted, type-checked and tested. ✅

## 📖 Lesson 13.8 — Senior engineer's code quality checklist
- [ ] Small functions with one job, clear names
- [ ] Type hints + docstrings on public functions
- [ ] No hard-coded secrets/paths; config via args/env
- [ ] Errors go to stderr; correct exit codes
- [ ] `--dry-run` for anything destructive
- [ ] Logging, not print, for tools
- [ ] Tests for the logic; external calls mocked
- [ ] Lint + format + tests run in CI

## ⚠️ Common mistakes
- Tests that hit real servers/APIs (slow, flaky, dangerous)
- Testing only the happy path — test the errors too!
- Logic buried inside `main()` with `print`s → hard to test. Put logic in pure functions

---

## 🧪 Labs
Solutions in [`solutions/`](solutions/): `ops_utils.py` + `test_ops_utils.py`.

### Lab 1 ⭐ — Test your validators
Copy `is_valid_ipv4` and `is_valid_port` from Module 06 and write parametrized tests
covering valid, invalid, and edge cases (`0`, `65535`, `"255.255.255.255"`).

### Lab 2 ⭐⭐ — Test file logic with tmp_path
Write `count_levels(path) -> dict[str, int]` and test it using a temp log file.
Also test that a missing file raises `FileNotFoundError`.

### Lab 3 ⭐⭐ — Mock subprocess
Write `service_is_active(name)` that runs `systemctl is-active NAME` and returns a bool.
Test both active and inactive cases with `unittest.mock.patch` — without running systemctl.

### Lab 4 ⭐⭐⭐ — Lint, type-check, CI
Run `ruff check`, `ruff format`, and `mypy` on your Module 10 scripts and fix everything.
Then add the GitHub Actions workflow above to your own repo and get a green ✅.

```bash
cd solutions && pytest -v
```

---

## ✅ Checkpoint
- [ ] I can write tests with parametrize, fixtures and tmp_path
- [ ] I mock subprocess/API calls in unit tests
- [ ] I can set up lint + type-check + tests in CI

👉 Next: [Module 14 — Capstone Projects](../14-capstone/README.md)
