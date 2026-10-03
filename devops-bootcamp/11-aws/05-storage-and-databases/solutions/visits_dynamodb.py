"""visits_dynamodb.py — demo-app's visit counter in DynamoDB instead of Redis.

DynamoDB is a serverless key-value database: no servers, pay per request. UpdateItem with ADD is ATOMIC, so many app
instances can count at the same time without losing updates (the same job Redis INCR did in Phases 4-7).

  python3 visits_dynamodb.py setup        create the table (on-demand billing)
  python3 visits_dynamodb.py hit [PAGE]   count one visit, print the new total
"""
import sys
import time

import boto3

TABLE = "demo-visits"
dynamodb = boto3.client("dynamodb")


def setup() -> None:
    dynamodb.create_table(
        TableName=TABLE,
        AttributeDefinitions=[{"AttributeName": "page", "AttributeType": "S"}],
        KeySchema=[{"AttributeName": "page", "KeyType": "HASH"}],     # partition key
        BillingMode="PAY_PER_REQUEST",                                 # no capacity planning
    )
    dynamodb.get_waiter("table_exists").wait(TableName=TABLE)
    # items can carry an expiry time: DynamoDB deletes them for free (sessions, caches, temp data)
    dynamodb.update_time_to_live(TableName=TABLE, TimeToLiveSpecification={"Enabled": True, "AttributeName": "expires_at"})
    print(f"table {TABLE} ready")


def hit(page: str = "/") -> int:
    resp = dynamodb.update_item(
        TableName=TABLE,
        Key={"page": {"S": page}},
        UpdateExpression="ADD visits :one SET last_visit = :now",
        ExpressionAttributeValues={":one": {"N": "1"}, ":now": {"N": str(int(time.time()))}},
        ReturnValues="UPDATED_NEW",
    )
    return int(resp["Attributes"]["visits"]["N"])


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "setup":
        setup()
    elif len(sys.argv) > 1 and sys.argv[1] == "hit":
        print(hit(sys.argv[2] if len(sys.argv) > 2 else "/"))
    else:
        sys.exit(__doc__)
