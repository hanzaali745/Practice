#!/usr/bin/env bash
# ecs_deploy.sh IMAGE — roll out IMAGE to the ECS service and wait until it is healthy (or rolled back)
#   copies the current task definition, swaps the image, registers it as a new revision, updates the service
# Needs: ECS_CLUSTER, ECS_SERVICE, TASK_FAMILY (deploy-aws.yml sets them from repository variables)
set -euo pipefail
image=${1:?usage: ecs_deploy.sh IMAGE   e.g. 123456789012.dkr.ecr.eu-west-1.amazonaws.com/demo-app@sha256:...}
: "${ECS_CLUSTER:?}" "${ECS_SERVICE:?}" "${TASK_FAMILY:?}"

# keep only the fields register-task-definition accepts (describe returns read-only ones like revision and status)
new_definition=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --query taskDefinition --output json |
    jq --arg image "$image" '.containerDefinitions[0].image = $image
        | {family, taskRoleArn, executionRoleArn, networkMode, containerDefinitions, volumes, placementConstraints,
           requiresCompatibilities, cpu, memory, runtimePlatform}
        | with_entries(select(.value != null))')
arn=$(aws ecs register-task-definition --cli-input-json "$new_definition" --query taskDefinition.taskDefinitionArn --output text)
echo "registered $arn"

aws ecs update-service --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE" --task-definition "$arn" > /dev/null
echo "rolling out to $ECS_CLUSTER/$ECS_SERVICE (new tasks must pass the load balancer health check)..."
if [[ -n ${AWS_ENDPOINT_URL:-} ]]; then
    echo "local AWS: skipping the wait (moto runs no tasks, so a service never becomes stable)"
else
    aws ecs wait services-stable --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE"
fi

# "stable" also happens after the circuit breaker ROLLED BACK — check which revision is actually running
running=$(aws ecs describe-services --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE" --query 'services[0].taskDefinition' --output text)
if [[ $running != "$arn" ]]; then
    echo "❌ the deployment failed and was rolled back to $running" >&2
    exit 1
fi
echo "✅ $ECS_SERVICE runs $arn"
