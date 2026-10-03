# Local AWS for practice (moto)

Most Phase 11 labs can run **without an AWS account** against [moto](https://github.com/getmoto/moto), a local
imitation of the AWS APIs. The same `aws` commands, boto3 scripts and many Terraform configs work — you just point them
at `http://localhost:5000`.

```bash
cd ~/Practice/devops-bootcamp/11-aws/local-aws
docker compose up -d                 # start the fake AWS
source env.sh                        # this shell now talks to it
aws sts get-caller-identity          # account 123456789012 — it's moto
aws s3 mb s3://my-first-bucket && aws s3 ls
./reset.sh                           # start over
source env.sh off                    # back to real AWS in this shell
```

**What moto is good for:** learning the CLI and APIs, testing boto3 scripts and automation, CI tests.
**What it can't do:** nothing really runs — EC2 instances don't boot, load balancers don't route, IAM permissions are
not enforced by default, costs and limits don't exist. Labs marked **☁️ real AWS** need a real (free-tier) account with
the Module 01 safety setup — and a `terraform destroy` the same day.
