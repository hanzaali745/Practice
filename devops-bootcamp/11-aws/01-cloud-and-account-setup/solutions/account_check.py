"""account_check.py — is this AWS account set up safely? Read-only; run it any time (boto3).

Checks: not using root · root has MFA and no access keys · a budget exists · a CloudTrail trail is logging ·
a password policy is set · no IAM user can sign in to the console without MFA.
"""
import sys

import boto3
from botocore.exceptions import ClientError

results: list[tuple[bool, str]] = []


def check(ok: bool, text: str) -> None:
    results.append((ok, text))
    print(("✅ " if ok else "❌ ") + text)


def main() -> int:
    sts, iam = boto3.client("sts"), boto3.client("iam")
    me = sts.get_caller_identity()
    print(f"account {me['Account']} as {me['Arn']}")
    summary = iam.get_account_summary()["SummaryMap"]

    check(not me["Arn"].endswith(":root"), "you are NOT using the root user")
    check(summary.get("AccountMFAEnabled", 0) == 1, "root user has MFA")
    check(summary.get("AccountAccessKeysPresent", 0) == 0, "root user has NO access keys")

    budgets = boto3.client("budgets").describe_budgets(AccountId=me["Account"]).get("Budgets", [])
    check(len(budgets) > 0, f"a budget exists ({', '.join(b['BudgetName'] for b in budgets) or 'none'})")

    ct = boto3.client("cloudtrail")
    trails = ct.describe_trails()["trailList"]
    logging = [t["Name"] for t in trails if ct.get_trail_status(Name=t["TrailARN"])["IsLogging"]]
    check(any(t.get("IsMultiRegionTrail") for t in trails) and bool(logging), "a multi-region CloudTrail trail is logging")

    try:
        iam.get_account_password_policy()
        check(True, "a password policy is set")
    except ClientError:
        check(False, "a password policy is set")

    no_mfa = []
    for user in iam.list_users()["Users"]:
        try:
            iam.get_login_profile(UserName=user["UserName"])          # has a console password
        except ClientError:
            continue
        if not iam.list_mfa_devices(UserName=user["UserName"])["MFADevices"]:
            no_mfa.append(user["UserName"])
    check(not no_mfa, f"no IAM user has console access without MFA {no_mfa or ''}".strip())

    return 0 if all(ok for ok, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
