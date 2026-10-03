#!/usr/bin/env bash
# deploy_lambda.sh | --cleanup — package and deploy stop_dev_instances as a Lambda function on a schedule:
#   role (least privilege: may only stop instances tagged env=dev) · function · log retention · EventBridge rule
# Local AWS: creates everything (moto can't run the code — that's what the pytest tests are for). ☁️ Real AWS: free tier.
set -euo pipefail
cd "$(dirname "$0")"
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
fn=stop-dev-instances
rule=stop-dev-instances-evening

if [[ ${1:-} == --cleanup ]]; then
    aws events remove-targets --rule "$rule" --ids 1 > /dev/null 2>&1 || true
    aws events delete-rule --name "$rule" 2>/dev/null || true
    aws lambda delete-function --function-name "$fn" > /dev/null 2>&1 || true
    aws logs delete-log-group --log-group-name "/aws/lambda/$fn" 2>/dev/null || true
    aws iam detach-role-policy --role-name "$fn" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true
    aws iam delete-role-policy --role-name "$fn" --policy-name stop-dev 2>/dev/null || true
    aws iam delete-role --role-name "$fn" 2>/dev/null || true
    echo "deleted $fn"; exit 0
fi

say "1. The function's role: logs + find instances + stop ONLY env=dev instances"
role_arn=$(aws iam create-role --role-name "$fn" --query Role.Arn --output text --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}')
aws iam attach-role-policy --role-name "$fn" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam put-role-policy --role-name "$fn" --policy-name stop-dev --policy-document file://lambda-policy.json
echo "$role_arn"
[[ -n ${AWS_ENDPOINT_URL:-} ]] || sleep 10           # ☁️ a brand-new role takes a few seconds to be usable by Lambda

say "2. Package and create the function"
build=$(mktemp -d)
trap 'rm -r "$build"' EXIT
python3 -m zipfile -c "$build/function.zip" lambda/stop_dev_instances.py
aws logs create-log-group --log-group-name "/aws/lambda/$fn" 2>/dev/null || true
aws logs put-retention-policy --log-group-name "/aws/lambda/$fn" --retention-in-days 14
fn_arn=$(aws lambda create-function --function-name "$fn" \
    --runtime python3.13 --architectures arm64 --handler stop_dev_instances.handler \
    --zip-file "fileb://$build/function.zip" --role "$role_arn" \
    --timeout 60 --memory-size 128 \
    --environment 'Variables={TAG_KEY=env,TAG_VALUE=dev,DRY_RUN=false}' \
    --tags project=lambda-lab --query FunctionArn --output text)
echo "$fn_arn"

say "3. Run it every weekday at 19:00 UTC"
rule_arn=$(aws events put-rule --name "$rule" --schedule-expression 'cron(0 19 ? * MON-FRI *)' --query RuleArn --output text)
aws lambda add-permission --function-name "$fn" --statement-id events-invoke --action lambda:InvokeFunction \
    --principal events.amazonaws.com --source-arn "$rule_arn" > /dev/null    # EventBridge may call it — nobody else
aws events put-targets --rule "$rule" --targets "Id=1,Arn=$fn_arn" --query FailedEntryCount --output text
aws events describe-rule --name "$rule" --query '{Rule: Name, Schedule: ScheduleExpression, State: State}' --output table

if [[ -z ${AWS_ENDPOINT_URL:-} ]]; then
    say "4. ☁️ Try it now (DRY_RUN would be safer on a shared account)"
    aws lambda invoke --function-name "$fn" --payload '{}' --cli-binary-format raw-in-base64-out /dev/stdout
    aws logs tail "/aws/lambda/$fn" --since 5m
fi
echo
echo "✅ clean up with: $0 --cleanup"
