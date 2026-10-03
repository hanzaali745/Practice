"""s3_tool.py — S3 the safe way, with boto3.

  create BUCKET                      private, encrypted, versioned bucket with a lifecycle policy
  put BUCKET KEY FILE                upload a file
  versions BUCKET KEY                list every version of an object
  restore BUCKET KEY VERSION_ID      make an old version the current one again (undo an overwrite/delete)
  presign BUCKET KEY [SECONDS]       a temporary download link — no public bucket needed

Works against real AWS or local AWS (source local-aws/env.sh).
"""
import sys

import boto3
from botocore.config import Config

s3 = boto3.client("s3", config=Config(signature_version="s3v4"))   # SigV4: required for KMS-encrypted objects


def create(bucket: str) -> None:
    region = s3.meta.region_name
    kwargs = {} if region == "us-east-1" else {"CreateBucketConfiguration": {"LocationConstraint": region}}
    s3.create_bucket(Bucket=bucket, **kwargs)
    s3.put_public_access_block(Bucket=bucket, PublicAccessBlockConfiguration={       # no public access, ever
        "BlockPublicAcls": True, "IgnorePublicAcls": True, "BlockPublicPolicy": True, "RestrictPublicBuckets": True})
    s3.put_bucket_encryption(Bucket=bucket, ServerSideEncryptionConfiguration={"Rules": [
        {"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}, "BucketKeyEnabled": True}]})
    s3.put_bucket_versioning(Bucket=bucket, VersioningConfiguration={"Status": "Enabled"})   # undo button
    s3.put_bucket_lifecycle_configuration(Bucket=bucket, LifecycleConfiguration={"Rules": [{
        "ID": "cheaper-then-gone",
        "Status": "Enabled",
        "Filter": {"Prefix": ""},
        "Transitions": [{"Days": 30, "StorageClass": "STANDARD_IA"}, {"Days": 90, "StorageClass": "GLACIER_IR"}],
        "NoncurrentVersionExpiration": {"NoncurrentDays": 30},            # old versions don't pile up forever
        "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": 7}}]})
    print(f"created s3://{bucket}: private, KMS-encrypted, versioned, lifecycle")


def put(bucket: str, key: str, path: str) -> str:
    with open(path, "rb") as f:
        version = s3.put_object(Bucket=bucket, Key=key, Body=f).get("VersionId")
    print(f"uploaded s3://{bucket}/{key} version {version}")
    return version


def versions(bucket: str, key: str) -> list[dict]:
    resp = s3.list_object_versions(Bucket=bucket, Prefix=key)
    items = [v for v in resp.get("Versions", []) if v["Key"] == key]
    items += [{**m, "Size": "-", "DeleteMarker": True} for m in resp.get("DeleteMarkers", []) if m["Key"] == key]
    for v in sorted(items, key=lambda v: v["LastModified"], reverse=True):
        flag = "  ← current" if v["IsLatest"] else ""
        kind = "DELETE MARKER" if v.get("DeleteMarker") else f"{v['Size']} bytes"
        print(f"{v['VersionId']}  {v['LastModified']:%Y-%m-%d %H:%M:%S}  {kind}{flag}")
    return items


def restore(bucket: str, key: str, version_id: str) -> None:
    # copying an old version onto the same key creates a NEW current version with the old content
    s3.copy_object(Bucket=bucket, Key=key, CopySource={"Bucket": bucket, "Key": key, "VersionId": version_id})
    print(f"restored s3://{bucket}/{key} from version {version_id}")


def presign(bucket: str, key: str, seconds: int = 900) -> str:
    url = s3.generate_presigned_url("get_object", Params={"Bucket": bucket, "Key": key}, ExpiresIn=seconds)
    print(url)
    return url


def main(argv: list[str]) -> None:
    commands = {"create": create, "put": put, "versions": versions, "restore": restore, "presign": presign}
    if len(argv) < 2 or argv[0] not in commands:
        sys.exit(__doc__)
    args = [int(a) if a.isdigit() and argv[0] == "presign" else a for a in argv[1:]]
    commands[argv[0]](*args)


if __name__ == "__main__":
    main(sys.argv[1:])
