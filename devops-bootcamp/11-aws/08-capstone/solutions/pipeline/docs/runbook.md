# demo-app on AWS — runbook

Every CloudWatch alarm links here. Start with the dashboard: CloudWatch → Alarms, then the ECS service's **Deployments**
and **Events** tabs.

```bash
aws ecs describe-services --cluster demo-app --services demo-app \
  --query 'services[0].{running: runningCount, desired: desiredCount, deployments: deployments[].[status, rolloutState, taskDefinition], events: events[:5].message}'
aws logs tail /ecs/demo-app --since 15m --filter-pattern '{ $.log.level = "error" }'
```

## demo-app-5xx-errors / demo-app-error-logs
1. Did a deployment just happen? (`deployments` above, or the latest **deploy-aws** run)
2. Yes → roll back: re-run the previous successful **deploy-aws** run (it redeploys that image by digest), or
   `aws ecs update-service --cluster demo-app --service demo-app --task-definition demo-app:<previous revision>`
3. No → read the error logs: is a dependency (database, Redis, another API) failing?

## demo-app-slow-p99
1. CPU high? (ECS service metrics) → autoscaling should be adding tasks; is it at `max_tasks`?
2. One slow endpoint? Logs Insights: `stats pct(event.duration, 99) by url.path`
3. A slow dependency? Check its own dashboard.

## demo-app-unhealthy-targets / demo-app-too-few-tasks
1. `events` above: "failed container health checks", "CannotPullContainerError", "ResourceInitializationError"?
2. Pull errors → NAT gateway or VPC endpoints, and the execution role.
3. Health check failures → the stopped task's reason:
   `aws ecs describe-tasks --cluster demo-app --tasks <id> --query 'tasks[0].stoppedReason'`
4. An AZ problem? Check the AWS Health Dashboard; tasks spread over two AZs should survive one.

## After the incident
Write a short blameless postmortem: timeline, impact, cause, and what makes it impossible (or detected sooner) next time.
