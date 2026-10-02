#!/usr/bin/env python3
"""List running EC2 instances to CSV. Usage: lab4_aws_inventory.py [--region eu-west-1] [--out ec2.csv]

Needs: pip install boto3, and AWS credentials (aws configure or env vars / IAM role).
"""
import argparse
import csv
import sys

import boto3
from botocore.exceptions import BotoCoreError, ClientError


def running_instances(region: str) -> list[dict]:
    ec2 = boto3.client("ec2", region_name=region)
    paginator = ec2.get_paginator("describe_instances")
    rows = []
    for page in paginator.paginate(Filters=[{"Name": "instance-state-name", "Values": ["running"]}]):
        for reservation in page["Reservations"]:
            for inst in reservation["Instances"]:
                tags = {t["Key"]: t["Value"] for t in inst.get("Tags", [])}
                rows.append({
                    "id": inst["InstanceId"],
                    "name": tags.get("Name", "-"),
                    "type": inst["InstanceType"],
                    "launched": inst["LaunchTime"].isoformat(),
                })
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--region", default="eu-west-1")
    parser.add_argument("--out", default="ec2.csv")
    args = parser.parse_args()
    try:
        rows = running_instances(args.region)
    except (BotoCoreError, ClientError) as e:
        print(f"AWS error: {e}", file=sys.stderr)
        return 1

    with open(args.out, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["id", "name", "type", "launched"])
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} instances to {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
