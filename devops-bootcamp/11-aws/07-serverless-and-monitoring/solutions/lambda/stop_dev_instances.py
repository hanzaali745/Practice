"""stop_dev_instances.py — a Lambda function that stops running EC2 instances tagged env=dev.

EventBridge runs it every weekday evening, so forgotten dev machines don't run all night. That is often a 60%+ saving on
non-production compute. Instances tagged keep-running=true are skipped, and DRY_RUN=true only reports what it would do.

Environment: TAG_KEY (default env) · TAG_VALUE (default dev) · DRY_RUN (default false)
"""
import json
import logging
import os

import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)


def find_instances(ec2, tag_key: str, tag_value: str) -> list[str]:
    ids = []
    pages = ec2.get_paginator("describe_instances").paginate(Filters=[
        {"Name": f"tag:{tag_key}", "Values": [tag_value]},
        {"Name": "instance-state-name", "Values": ["running"]},
    ])
    for page in pages:                                         # paginate: there may be more than one page
        for reservation in page["Reservations"]:
            for instance in reservation["Instances"]:
                tags = {t["Key"]: t["Value"] for t in instance.get("Tags", [])}
                if tags.get("keep-running", "").lower() != "true":
                    ids.append(instance["InstanceId"])
    return sorted(ids)


def handler(event, context):
    """Lambda entry point: EventBridge passes the scheduled event; we don't need anything from it."""
    tag_key = os.environ.get("TAG_KEY", "env")
    tag_value = os.environ.get("TAG_VALUE", "dev")
    dry_run = os.environ.get("DRY_RUN", "false").lower() == "true"
    ec2 = boto3.client("ec2")                                  # credentials come from the function's role

    ids = find_instances(ec2, tag_key, tag_value)
    if ids and not dry_run:
        ec2.stop_instances(InstanceIds=ids)
    result = {"stopped": ids, "count": len(ids), "dry_run": dry_run}
    log.info(json.dumps(result))                               # one JSON line: searchable in Logs Insights
    return result
