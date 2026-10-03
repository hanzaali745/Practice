"""Tests for iam_audit.py with moto's in-process mock — no AWS account, no server needed.   python3 -m pytest -q"""
import json
import os
import subprocess
import sys
from pathlib import Path

import boto3
import pytest
from moto import mock_aws

HERE = Path(__file__).parent
ADMIN = {"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}]}
OPEN_TRUST = {"Version": "2012-10-17",
              "Statement": [{"Effect": "Allow", "Principal": {"AWS": "*"}, "Action": "sts:AssumeRole"}]}


@pytest.fixture
def aws(monkeypatch):
    for var in ("AWS_ENDPOINT_URL", "AWS_PROFILE"):
        monkeypatch.delenv(var, raising=False)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "test")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "test")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-west-1")
    with mock_aws():
        yield boto3.client("iam")


def run_audit() -> tuple[int, str]:
    """Run the audit in THIS process (so moto's mock applies) and capture what it prints."""
    import importlib
    import io
    from contextlib import redirect_stdout

    sys.path.insert(0, str(HERE))
    import iam_audit
    importlib.reload(iam_audit)                    # fresh client inside the mock
    out = io.StringIO()
    sys.argv = ["iam_audit.py"]
    with redirect_stdout(out):
        code = iam_audit.main()
    return code, out.getvalue()


def test_clean_account_has_no_findings(aws):
    aws.create_group(GroupName="developers")
    aws.create_user(UserName="alice")
    aws.add_user_to_group(GroupName="developers", UserName="alice")
    code, out = run_audit()
    assert code == 0 and "no findings" in out


def test_finds_the_classic_problems(aws):
    arn = aws.create_policy(PolicyName="god-mode", PolicyDocument=json.dumps(ADMIN))["Policy"]["Arn"]
    aws.create_user(UserName="bob")
    aws.create_login_profile(UserName="bob", Password="Sup3r-Secret-Pass!")      # console, no MFA
    aws.attach_user_policy(UserName="bob", PolicyArn=arn)                         # direct + admin
    aws.create_role(RoleName="open-door", AssumeRolePolicyDocument=json.dumps(OPEN_TRUST))
    code, out = run_audit()
    assert code == 1
    assert "bob: console password but no MFA" in out
    assert "bob: policies attached directly" in out
    assert "bob: has full admin" in out
    assert "role open-door: ANYONE can assume it" in out


def test_script_runs_standalone():
    """Smoke test: the file is valid Python with a --help."""
    env = {**os.environ, "AWS_DEFAULT_REGION": "eu-west-1"}
    r = subprocess.run([sys.executable, str(HERE / "iam_audit.py"), "--help"], capture_output=True, text=True, env=env)
    assert r.returncode == 0 and "max-key-age" in r.stdout
