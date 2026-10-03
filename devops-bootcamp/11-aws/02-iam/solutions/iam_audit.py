"""iam_audit.py — find the IAM problems attackers look for (read-only, boto3).

  * users with console access but no MFA
  * access keys older than 90 days (rotate them — or better, replace them with SSO/roles)
  * policies granting "*" on "*" attached to users/groups/roles (AdministratorAccess or hand-written)
  * roles that anyone (Principal "*") may assume
  * users with policies attached directly instead of through groups

Usage: python3 iam_audit.py [--max-key-age DAYS]       exit code 1 if anything was found
"""
import argparse
import json
import sys
import urllib.parse
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

iam = boto3.client("iam")
findings: list[str] = []


def find(text: str) -> None:
    findings.append(text)
    print("❌ " + text)


def is_admin(document: dict) -> bool:
    statements = document["Statement"]
    statements = statements if isinstance(statements, list) else [statements]
    for s in statements:
        actions = s.get("Action", [])
        resources = s.get("Resource", [])
        actions = actions if isinstance(actions, list) else [actions]
        resources = resources if isinstance(resources, list) else [resources]
        if s.get("Effect") == "Allow" and "*" in actions and "*" in resources:
            return True
    return False


def policy_document(arn: str) -> dict:
    version = iam.get_policy(PolicyArn=arn)["Policy"]["DefaultVersionId"]
    doc = iam.get_policy_version(PolicyArn=arn, VersionId=version)["PolicyVersion"]["Document"]
    return json.loads(urllib.parse.unquote(doc)) if isinstance(doc, str) else doc


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-key-age", type=int, default=90)
    args = parser.parse_args()
    now = datetime.now(timezone.utc)

    for user in iam.list_users()["Users"]:
        name = user["UserName"]
        try:
            iam.get_login_profile(UserName=name)
            if not iam.list_mfa_devices(UserName=name)["MFADevices"]:
                find(f"user {name}: console password but no MFA")
        except ClientError:
            pass
        for key in iam.list_access_keys(UserName=name)["AccessKeyMetadata"]:
            age = (now - key["CreateDate"]).days
            if key["Status"] == "Active" and age > args.max_key_age:
                find(f"user {name}: access key {key['AccessKeyId']} is {age} days old")
        direct = iam.list_attached_user_policies(UserName=name)["AttachedPolicies"]
        if direct:
            find(f"user {name}: policies attached directly ({', '.join(p['PolicyName'] for p in direct)}) — use groups")
        for p in direct:
            if is_admin(policy_document(p["PolicyArn"])):
                find(f"user {name}: has full admin ({p['PolicyName']})")

    for group in iam.list_groups()["Groups"]:
        for p in iam.list_attached_group_policies(GroupName=group["GroupName"])["AttachedPolicies"]:
            if is_admin(policy_document(p["PolicyArn"])):
                find(f"group {group['GroupName']}: has full admin ({p['PolicyName']}) — who is in it?")

    for role in iam.list_roles()["Roles"]:
        trust = role["AssumeRolePolicyDocument"]
        trust = json.loads(urllib.parse.unquote(trust)) if isinstance(trust, str) else trust
        for s in trust["Statement"]:
            principal = s.get("Principal", {})
            if s.get("Effect") == "Allow" and (principal == "*" or principal.get("AWS") == "*"):
                find(f"role {role['RoleName']}: ANYONE can assume it")

    print(f"\n{len(findings)} finding(s)" if findings else "✅ no findings")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
