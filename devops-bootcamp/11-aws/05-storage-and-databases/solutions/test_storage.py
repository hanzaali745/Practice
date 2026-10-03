"""Tests for s3_tool.py and visits_dynamodb.py with moto's in-process mock.   python3 -m pytest -q"""
import importlib
import sys
import urllib.parse
from pathlib import Path

import boto3
import pytest
from moto import mock_aws

sys.path.insert(0, str(Path(__file__).parent))


@pytest.fixture
def aws(monkeypatch):
    for var in ("AWS_ENDPOINT_URL", "AWS_PROFILE"):
        monkeypatch.delenv(var, raising=False)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "test")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "test")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-west-1")
    with mock_aws():
        yield


def load(name):
    module = importlib.import_module(name)
    return importlib.reload(module)          # new boto3 clients inside the mock


def test_bucket_is_secure_by_default(aws):
    s3_tool = load("s3_tool")
    s3_tool.create("bootcamp-reports")
    s3 = boto3.client("s3")
    block = s3.get_public_access_block(Bucket="bootcamp-reports")["PublicAccessBlockConfiguration"]
    assert all(block.values())
    assert s3.get_bucket_versioning(Bucket="bootcamp-reports")["Status"] == "Enabled"
    rule = s3.get_bucket_encryption(Bucket="bootcamp-reports")["ServerSideEncryptionConfiguration"]["Rules"][0]
    assert rule["ApplyServerSideEncryptionByDefault"]["SSEAlgorithm"] == "aws:kms"
    lifecycle = s3.get_bucket_lifecycle_configuration(Bucket="bootcamp-reports")["Rules"][0]
    assert lifecycle["NoncurrentVersionExpiration"]["NoncurrentDays"] == 30


def test_restore_undoes_an_overwrite(aws, tmp_path):
    s3_tool = load("s3_tool")
    s3_tool.create("bootcamp-reports")
    s3 = boto3.client("s3")
    ids = []
    for content in (b"good report", b"oops, overwritten"):
        f = tmp_path / "r.txt"
        f.write_bytes(content)
        ids.append(s3_tool.put("bootcamp-reports", "r.txt", str(f)))
    s3_tool.restore("bootcamp-reports", "r.txt", ids[0])        # by version id: timestamps can be equal
    assert s3.get_object(Bucket="bootcamp-reports", Key="r.txt")["Body"].read() == b"good report"
    assert len(s3_tool.versions("bootcamp-reports", "r.txt")) == 3          # history is kept


def test_presigned_url_expires(aws):
    s3_tool = load("s3_tool")
    s3_tool.create("bootcamp-reports")
    url = s3_tool.presign("bootcamp-reports", "r.txt", 600)
    query = urllib.parse.parse_qs(urllib.parse.urlparse(url).query)
    assert query["X-Amz-Expires"] == ["600"]


def test_dynamodb_counter_counts_per_page(aws):
    # Real DynamoDB makes "ADD visits :one" ATOMIC across any number of clients. moto's in-memory imitation is not
    # thread-safe, so a concurrency test here would test moto, not our code — test the logic sequentially instead.
    visits = load("visits_dynamodb")
    visits.setup()
    for _ in range(50):
        visits.hit("/")
    assert visits.hit("/") == 51
    assert visits.hit("/other") == 1
