# AWS Module 03 — Networking: VPC 🟡

## 🎯 Objectives
- Plan a VPC's IP ranges and subnets across availability zones
- Explain what makes a subnet **public** or **private** (route tables, internet gateway, NAT gateway)
- Control traffic with **security groups** (chained by reference) and know when **NACLs** matter
- Keep private traffic private with **VPC endpoints**; see traffic with **flow logs**
- Build (and tear down) a whole VPC with the CLI, then recognise it in Terraform

## 🧠 Why DevOps engineers care
Every server, container, database and load balancer you run on AWS lives in a VPC. "Why can't my app reach the
database?" and "why is this server on the internet?" are VPC questions — and the classic security mistakes (databases in
public subnets, `0.0.0.0/0` on SSH) are VPC mistakes. You need to be able to draw your network and explain every arrow.

---

## 📖 Lesson 3.1 — The picture

```
 VPC 10.20.0.0/16 (eu-west-1)
 ┌──────────────── AZ a ─────────────────┐ ┌──────────────── AZ b ─────────────────┐
 │ public  10.20.0.0/20                  │ │ public  10.20.16.0/20                 │   route: 0.0.0.0/0 → Internet Gateway
 │   load balancer · NAT gateway         │ │   load balancer                       │
 ├───────────────────────────────────────┤ ├───────────────────────────────────────┤
 │ private 10.20.128.0/20                │ │ private 10.20.144.0/20                │   route: 0.0.0.0/0 → NAT (outbound only)
 │   demo-app tasks/instances · database │ │   demo-app · database replica         │   or no internet at all + VPC endpoints
 └───────────────────────────────────────┘ └───────────────────────────────────────┘
```
- **Public subnet** = its route table sends `0.0.0.0/0` to an **internet gateway**. Only load balancers and NAT go here.
- **Private subnet** = no route from the internet. Apps and databases live here. Outbound internet (updates, APIs)
  through a **NAT gateway** (costs money) — or none at all, using **VPC endpoints** for AWS services (S3, ECR, logs).
- Two (or three) AZs, so one data-centre failure doesn't take you down.

## 📖 Lesson 3.2 — Planning addresses

Use a private range (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) that doesn't overlap your office, VPN or other
VPCs — you will want to connect them one day. `/16` for the VPC, `/20`–`/24` per subnet; AWS keeps 5 addresses per subnet.
```bash
python3 solutions/cidr_planner.py 10.20.0.0/16 --azs 2 --prefix 20
```

## 📖 Lesson 3.3 — Security groups and NACLs

| | Security group | Network ACL |
|--|----------------|-------------|
| Attached to | network interfaces (instances, tasks, load balancers, databases) | subnets |
| Rules | allow only | allow and deny, numbered |
| State | **stateful** (replies are allowed automatically) | stateless (allow both directions) |
| Use for | almost everything | rare coarse blocks (e.g. deny a bad IP range) |

Chain security groups **by reference**, not by IP:
```
internet ──443──► sg alb ──8000──► sg app ──5432──► sg db
aws ec2 authorize-security-group-ingress --group-id $app --protocol tcp --port 8000 --source-group $alb
```
Then "only the load balancer can reach the app, only the app can reach the database" stays true however many
instances come and go. Never open SSH (22) to `0.0.0.0/0` — use **SSM Session Manager** (Module 04).

## 📖 Lesson 3.4 — Endpoints, flow logs, connections

- **Gateway endpoints** (S3, DynamoDB, free) and **interface endpoints** (ECR, CloudWatch Logs, STS…, paid per hour):
  AWS traffic stays inside AWS — no NAT needed, cheaper and safer.
- **VPC flow logs** → CloudWatch Logs or S3: who talked to whom, accepted or rejected. The first place to look when
  "the connection times out".
- Connecting networks: **VPC peering** (two VPCs), **Transit Gateway** (many), **Site-to-Site VPN / Direct Connect**
  (on-premises).

## 📖 Lesson 3.5 — By hand, then as code

[`vpc_lab.sh`](solutions/vpc_lab.sh) builds everything in Lesson 3.1 with the CLI (and `--cleanup` deletes it in the right
order — dependencies matter: NAT before IP, associations before route tables, subnets before the VPC). Doing it once by
hand is the best way to understand it; afterwards always use code. Compare with the Terraform network in
[Phase 6, Module 08](../../6-terraform/08-aws-with-terraform/README.md) — and in real projects the community module
`terraform-aws-modules/vpc/aws`.

---

## ⚠️ Common mistakes
- Databases or app servers in public subnets "to make it work"
- Security groups with `0.0.0.0/0` on SSH, RDP or database ports
- A NAT gateway per AZ left running in a lab account (~$1/day each, plus data)
- Overlapping CIDRs that make peering/VPN impossible later
- Debugging connectivity by opening everything instead of reading flow logs

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). Labs 1–3 run on local AWS; Lab 4 needs **☁️ a real account**.

### Lab 1 ⭐ — Plan it
Write `cidr_planner.py` with tests: split a `/16` into public and private `/20`s for 2 or 3 AZs, reject public ranges
and impossible sizes. Draw your VPC on paper with the output.

### Lab 2 ⭐⭐ — Build it by hand
Write `vpc_lab.sh`: VPC, 4 subnets in 2 AZs, internet gateway, public and private route tables, and three chained
security groups. Print a table of subnets and security group rules with `--query`.

### Lab 3 ⭐⭐ — Tear it down
Add `--cleanup` that deletes everything tagged `project=vpc-lab` in the right order. Run build → cleanup → build →
cleanup, and prove nothing is left.

### Lab 4 ⭐⭐⭐ — ☁️ Real traffic
In your real account: build the VPC with `--with-nat`, launch a tiny instance in a private subnet (Module 04), confirm it
can reach the internet but nothing can reach it, enable flow logs and find its traffic. Then `--cleanup` — check the
NAT gateway is gone.

---

## ✅ Checkpoint
- [ ] I can plan non-overlapping CIDRs across AZs
- [ ] I can explain public vs private subnets, IGW vs NAT, and when to use VPC endpoints
- [ ] I chain security groups by reference and never expose admin ports
- [ ] I can build and cleanly delete a VPC, and read flow logs to debug connectivity

👉 Next: [Module 04 — Compute: EC2, Auto Scaling & Load Balancers](../04-compute/README.md)
