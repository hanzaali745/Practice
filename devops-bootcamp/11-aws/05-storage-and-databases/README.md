# AWS Module 05 — Storage & Databases 🟡

## 🎯 Objectives
- Choose between S3, EBS, EFS, RDS and DynamoDB for a job
- Create **S3** buckets that are private, encrypted, versioned and lifecycle-managed — and undo mistakes with versions
- Share files safely with **presigned URLs**
- Run **RDS** PostgreSQL privately, encrypted, backed up, with the password in **Secrets Manager**
- Use **DynamoDB** for serverless key-value data with atomic counters and TTL
- Automate it all with boto3 — and test it offline with moto

## 🧠 Why DevOps engineers care
Data outlives servers. Losing it, leaking it or paying too much for it are the most expensive cloud mistakes there are —
public S3 buckets have exposed millions of records, and a missing backup has ended companies. DevOps engineers set the
defaults (private, encrypted, versioned, backed up, expiring) so that the safe thing is the easy thing.

---

## 📖 Lesson 5.1 — Which storage?

| Service | Kind | Use for |
|---------|------|---------|
| **S3** | object storage, unlimited, 11 nines durability | files, backups, logs, static sites, Terraform state, data lakes |
| **EBS** | block disk for one instance (one AZ) | an instance's root/data volume; snapshot it |
| **EFS** | shared NFS file system across AZs | files many instances must share |
| **RDS / Aurora** | managed relational database (PostgreSQL, MySQL…) | most application data |
| **DynamoDB** | serverless key-value/document DB | high-scale simple access patterns, counters, sessions |
| **ElastiCache** | managed Redis/Valkey | caching, the Redis from Phases 4–7 |

## 📖 Lesson 5.2 — S3 done right

```bash
python3 solutions/s3_tool.py create bootcamp-reports-<you>     # names are global: add something unique
```
What `create` sets, and why:
| Setting | Why |
|---------|-----|
| **Block Public Access** (all four) | a private bucket can't be made public by accident |
| **Default encryption** (SSE-KMS, bucket key) | encrypted at rest, with an auditable key |
| **Versioning** | overwrites and deletes become recoverable |
| **Lifecycle** | → Standard-IA after 30 days → Glacier IR after 90; old versions deleted after 30 days |

```bash
python3 solutions/s3_tool.py put bootcamp-reports-you report.txt ./report.txt     # twice, with different content
python3 solutions/s3_tool.py versions bootcamp-reports-you report.txt
python3 solutions/s3_tool.py restore bootcamp-reports-you report.txt <old-version-id>   # undo!
python3 solutions/s3_tool.py presign bootcamp-reports-you report.txt 900               # a 15-minute link
```
**Presigned URLs** let someone download one object for a while — no public bucket, no credentials shared. (They use
Signature V4, which KMS-encrypted objects require — the tool sets that explicitly.) Bucket **policies** add rules like
"HTTPS only" or "only from this VPC endpoint".

## 📖 Lesson 5.3 — RDS

```bash
./solutions/rds_lab.sh      # PostgreSQL in the private subnets of the Module 03 VPC
```
- **Private** (`--no-publicly-accessible`), reachable only from the `app` security group
- **Encrypted** storage, **automated backups** (point-in-time restore for 7 days), **deletion protection**
- `--manage-master-user-password`: RDS generates the password and keeps it in **Secrets Manager** (rotated); the app
  reads it at start-up with its IAM role — no password in code, config or Terraform state
- Production: **Multi-AZ** (a standby in another AZ, automatic failover), read replicas, parameter groups, upgrades in a
  maintenance window. **Aurora** for more scale.

## 📖 Lesson 5.4 — DynamoDB

```bash
python3 solutions/visits_dynamodb.py setup      # table "demo-visits", on-demand billing, TTL enabled
python3 solutions/visits_dynamodb.py hit /      # 1, 2, 3...
```
`UpdateItem` with `ADD visits :one` is **atomic**: a hundred app instances can count at once without losing updates —
what Redis `INCR` did for demo-app earlier. Design tables around your **access patterns** (partition key first), not
around joins.

## 📖 Lesson 5.5 — Test storage code offline

[`test_storage.py`](solutions/test_storage.py) checks with moto's in-process mock that buckets are secure by default,
that `restore` really undoes an overwrite, that presigned URLs expire, and that the counter counts. Two lessons that came
out of writing these tests: identify versions by **version id** (two uploads can share a timestamp), and don't test
*AWS's* guarantees (like DynamoDB atomicity) against a mock that doesn't implement them under concurrency — test your
logic, and test the platform in a sandbox account.

---

## ⚠️ Common mistakes
- Public buckets, or "temporarily" disabling Block Public Access
- No versioning on buckets holding anything important; no lifecycle → paying for every old version forever
- Databases with public endpoints, default passwords in code, no backups or no restore test
- One huge DynamoDB partition key value (a "hot key") or table design copied from SQL
- Deleting a bucket/database in a lab without noticing it was shared

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `python3 -m pytest -q` runs offline; scripts run on local AWS.

### Lab 1 ⭐⭐ — A safe bucket
Write `s3_tool.py create` with block public access, KMS encryption, versioning and a lifecycle rule, and a test that
checks each setting. Try to make the bucket public afterwards (`put-bucket-policy` with `"Principal": "*"`) — on ☁️ real
AWS, what happens?

### Lab 2 ⭐⭐ — The undo button
Upload a file twice, list versions, restore the first one, delete the object and bring it back (remove the delete
marker or copy the last real version). Generate a presigned link and open it before and after it expires (☁️).

### Lab 3 ⭐⭐ — A database done right
Run `rds_lab.sh` on top of `vpc_lab.sh`. Check every security property in the output; then `--cleanup`. ☁️ On real AWS,
connect from an instance in the private subnet via SSM using the secret's password.

### Lab 4 ⭐⭐⭐ — demo-app on DynamoDB
Write `visits_dynamodb.py` with an atomic counter and TTL, and tests with moto. Bonus: change demo-app's `/visits` to
use DynamoDB when `DYNAMODB_TABLE` is set (boto3 is the only new dependency).

---

## ✅ Checkpoint
- [ ] I can pick the right storage service for a job
- [ ] My buckets are private, encrypted, versioned and lifecycle-managed; I use presigned URLs to share
- [ ] My databases are private, encrypted, backed up, and their passwords live in Secrets Manager
- [ ] I can use DynamoDB atomically and test storage code with moto

👉 Next: [Module 06 — Containers on AWS](../06-containers-on-aws/README.md)
