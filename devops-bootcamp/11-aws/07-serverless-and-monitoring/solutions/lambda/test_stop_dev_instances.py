"""Tests for the Lambda handler with moto's in-process mock — no AWS account needed.   python3 -m pytest -q"""
import sys
from pathlib import Path

import boto3
import pytest
from moto import mock_aws

sys.path.insert(0, str(Path(__file__).parent))
import stop_dev_instances  # noqa: E402


@pytest.fixture
def ec2(monkeypatch):
    for var in ("AWS_ENDPOINT_URL", "AWS_PROFILE", "DRY_RUN"):
        monkeypatch.delenv(var, raising=False)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "test")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "test")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-west-1")
    with mock_aws():
        yield boto3.client("ec2")


def launch(ec2, **tags) -> str:
    ami = ec2.describe_images(Owners=["amazon"])["Images"][0]["ImageId"]
    spec = [{"ResourceType": "instance", "Tags": [{"Key": k.replace("_", "-"), "Value": v} for k, v in tags.items()]}]
    return ec2.run_instances(ImageId=ami, MinCount=1, MaxCount=1, InstanceType="t3.micro",
                             TagSpecifications=spec)["Instances"][0]["InstanceId"]


def state(ec2, instance_id: str) -> str:
    return ec2.describe_instances(InstanceIds=[instance_id])["Reservations"][0]["Instances"][0]["State"]["Name"]


def test_stops_only_running_dev_instances(ec2):
    dev, prod, kept = launch(ec2, env="dev"), launch(ec2, env="prod"), launch(ec2, env="dev", keep_running="true")
    result = stop_dev_instances.handler({}, None)
    assert result == {"stopped": [dev], "count": 1, "dry_run": False}
    assert state(ec2, dev) == "stopped"
    assert state(ec2, prod) == "running"
    assert state(ec2, kept) == "running"


def test_dry_run_changes_nothing(ec2, monkeypatch):
    monkeypatch.setenv("DRY_RUN", "true")
    dev = launch(ec2, env="dev")
    assert stop_dev_instances.handler({}, None)["stopped"] == [dev]
    assert state(ec2, dev) == "running"


def test_nothing_to_do(ec2):
    assert stop_dev_instances.handler({}, None)["count"] == 0


def test_tag_is_configurable(ec2, monkeypatch):
    monkeypatch.setenv("TAG_KEY", "stage")
    monkeypatch.setenv("TAG_VALUE", "test")
    target = launch(ec2, stage="test")
    assert stop_dev_instances.handler({}, None)["stopped"] == [target]
