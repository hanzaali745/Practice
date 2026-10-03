# env.sh — point the AWS CLI, boto3 and Terraform at the LOCAL fake AWS (moto) in THIS shell.
#   source ~/Practice/devops-bootcamp/11-aws/local-aws/env.sh      (then every `aws ...` command goes to moto)
#   source ~/Practice/devops-bootcamp/11-aws/local-aws/env.sh off  (back to your real AWS profile)
if [ "${1:-}" = "off" ]; then
    unset AWS_ENDPOINT_URL AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION AWS_REGION
    echo "☁️  real AWS (profile: ${AWS_PROFILE:-default}) — careful, this costs money"
else
    export AWS_ENDPOINT_URL=http://localhost:5000    # honoured by AWS CLI v2 and boto3
    export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test    # moto accepts anything
    export AWS_DEFAULT_REGION=eu-west-1 AWS_REGION=eu-west-1
    unset AWS_PROFILE
    echo "🧪 local fake AWS at $AWS_ENDPOINT_URL (start it with: docker compose up -d in local-aws/)"
fi
