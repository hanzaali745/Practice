# AWS Module 07 — Serverless & Monitoring: Lambda, EventBridge, CloudWatch 🔴

## 🎯 Objectives
- Write, test and deploy a **Lambda** function, with a least-privilege role and log retention
- Run it on a schedule, or on events, with **EventBridge**
- Automate AWS itself with boto3: here, a cost-saving "stop dev instances every evening" job
- Use **CloudWatch** end to end: logs, metric filters, custom metrics, alarms, **SNS** notifications, dashboards and
  Logs Insights
- Know AWS's audit and security monitoring: CloudTrail, Config, GuardDuty and Security Hub

## 🧠 Why DevOps engineers care
Much DevOps work on AWS is "glue": stop what nobody uses, react when something changes, alert when something breaks.
Lambda + EventBridge is that glue, costing cents a month. CloudWatch is where every AWS service already sends its metrics
and logs, so it is the monitoring you have on day one, before (or alongside) Prometheus and ELK from Phases 9–10.

---

## 📖 Lesson 7.1 — Lambda in five facts
1. You upload a **handler** function (`file.function`); AWS runs it when an **event** arrives. You don't manage servers.
2. You pay per request and per GB-second. A million short runs a month fits in the free tier.
3. Limits: 15 minutes max, up to 10 GB memory (CPU scales with it), `/tmp` up to 10 GB. Long jobs → ECS (Module 06).
4. Its permissions come from an **execution role**. Its logs go to `/aws/lambda/<name>`. Set retention!
5. **Cold starts**: the first call after idle starts a fresh environment. Create clients outside the handler to reuse
   them between calls, and keep packages small.

## 📖 Lesson 7.2 — An automation that pays for itself

[`stop_dev_instances.py`](solutions/lambda/stop_dev_instances.py) finds running instances tagged `env=dev` (with pagination),
skips any tagged `keep-running=true`, stops the rest and logs one JSON line. It has a `DRY_RUN` switch.

```bash
cd solutions/lambda && python3 -m pytest -q        # 4 tests with moto: dev stopped, prod untouched, dry run, config
cd .. && ./deploy_lambda.sh                         # role + function + EventBridge schedule (weekdays 19:00 UTC)
```
Look at [`lambda-policy.json`](solutions/lambda-policy.json): the function may **only** stop instances tagged
`env=dev`, using an IAM condition on `aws:ResourceTag/env`. So a bug in the code can't stop production.

## 📖 Lesson 7.3 — EventBridge

| Event source | Example |
|--------------|---------|
| **Schedule** | `cron(0 19 ? * MON-FRI *)` or `rate(5 minutes)`. Use **EventBridge Scheduler** for time zones and one-off runs |
| **AWS service events** | "EC2 instance state changed", "ECR scan found CRITICAL", "ECS task stopped" |
| **Your events** | `aws events put-events` from your own apps |

A **rule** matches events, using a pattern such as `{"source": ["aws.ecr"], "detail-type": ["ECR Image Scan"]}`, and sends
them to **targets**: Lambda, SNS, SQS or Step Functions. The target needs a resource permission so EventBridge, and only
EventBridge, can invoke it (`aws lambda add-permission --source-arn <rule>`).

Bigger serverless apps add API Gateway, SQS, DynamoDB and Step Functions, deployed with **SAM** or Terraform. The
build–test–deploy discipline from Phase 8 doesn't change.

## 📖 Lesson 7.4 — CloudWatch end to end

```bash
ALERT_EMAIL=you@example.com ./solutions/cloudwatch_lab.sh
```
| Piece | What the lab does |
|-------|-------------------|
| **Metrics** | AWS services publish them for free (EC2, ALB, ECS, RDS, Lambda…). Yours: `put-metric-data`, or the Embedded Metric Format in logs |
| **Logs** | log group `/demo/app` with **14-day retention**, holding demo-app's JSON lines (`LOG_FORMAT=json`) |
| **Metric filter** | `{ $.log.level = "error" }` → metric `DemoApp/Errors`: count from logs, alarm on the count |
| **Alarm** | Sum ≥ 5 in 5 minutes → SNS, with an OK action and a **runbook link** in the description (as in Phase 9) |
| **SNS** | fans out to email, SMS, Lambda, Slack/Chatbot, PagerDuty… |
| **Test the path** | `set-alarm-state --state-value ALARM`: prove the alert arrives before you need it |
| **Dashboard** | [`dashboard.json`](solutions/dashboard.json): errors, ECS CPU and a live Logs Insights widget |

**Logs Insights** is CloudWatch's query language. JSON fields are found automatically:
```
fields @timestamp, message, http.response.status_code
| filter log.level = "error"
| stats count() by bin(5m)
```
Good alarms to have on the Module 06 service:
- ALB `HTTPCode_Target_5XX_Count` and `TargetResponseTime` p99
- ECS `CPUUtilization`, and a `RunningTaskCount` below the desired count
- RDS `FreeStorageSpace`
- Lambda `Errors` and `Throttles`

**CloudWatch or Prometheus/Grafana?** CloudWatch needs no setup and covers AWS services. Prometheus and Grafana (Phase 9)
are better for app metrics, PromQL and multi-cloud. Many teams use both: Grafana can read CloudWatch, and Amazon Managed
Prometheus and Grafana exist.

## 📖 Lesson 7.5 — Audit & security monitoring (turn on in every account)

| Service | Answers |
|---------|---------|
| **CloudTrail** | *Who* did *what*, *when*, from *where*. Every API call. Use an organization trail to an S3 bucket in a log-archive account |
| **AWS Config** | What did this resource look like last Tuesday? Is every bucket encrypted? (rules + history) |
| **GuardDuty** | Threat detection: leaked keys used from odd places, crypto-mining, port scans |
| **Security Hub** | One place for findings from all of the above, scored against CIS/AWS best practices |
| **IAM Access Analyzer** | What is shared outside the account? Which permissions are unused? |

```bash
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=StopInstances --max-results 5
```
☁️ This shows your Lambda stopping instances, with its role as the identity: an audit trail for every automation.

---

## ⚠️ Common mistakes
- Lambda roles with `ec2:*` or `*`. Use conditions and resource ARNs to scope what automation may touch
- Automations without a **dry run**, without tests, or without logging what they changed
- Log groups that never expire, and noisy, verbose logs → a surprise CloudWatch bill
- Alarms nobody receives (unconfirmed SNS email), alarms without runbooks, alarms on every blip
- `treat-missing-data` left at its default, so a quiet metric looks like "insufficient data" forever
- CloudTrail only in one region, or trail logs in the same account an attacker controls

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/). `pytest` runs offline; the scripts run on local AWS.

### Lab 1 ⭐⭐ — Test-first automation
Write `stop_dev_instances.py` and its moto tests **before** deploying: dev stopped, prod untouched, `keep-running`
honoured, dry run changes nothing. Add a test for more than one page of results.

### Lab 2 ⭐⭐ — Deploy it on a schedule
Write `deploy_lambda.sh` with a least-privilege role (conditions on the tag), log retention and an EventBridge rule.
☁️ Launch a `t3.micro` tagged `env=dev`, invoke the function and find the `StopInstances` call in CloudTrail.

### Lab 3 ⭐⭐ — Logs to alarm to inbox
Run `cloudwatch_lab.sh` with your email. ☁️ Confirm the subscription, force the alarm and receive it. Then make it fire
for real: run demo-app's `/error` endpoint behind the Module 06 service, and watch the metric filter count.

### Lab 4 ⭐⭐⭐ — React to events
Write an EventBridge rule that sends **ECR scan results with CRITICAL findings** (Module 06) to the SNS topic, with an
input transformer that turns them into a one-line message: `CRITICAL CVEs in demo-app:sha-abc123 — 3 found`.

---

## ✅ Checkpoint
- [ ] I can write, test (moto), package and deploy a Lambda function with a least-privilege role
- [ ] I can trigger code on schedules and AWS events with EventBridge
- [ ] I can turn logs into metrics, metrics into alarms and alarms into notifications, and test that path
- [ ] I know what CloudTrail, Config, GuardDuty and Security Hub are for, and turn them on

👉 Next: [Module 08 — Capstone: demo-app on AWS](../08-capstone/README.md)
