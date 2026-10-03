# DevOps interview question bank

Answer each **out loud** in 1–2 minutes before you read the [model answers](solutions/answers.md) (same numbering).
Mark the ones you stumbled on and repeat them a week later. 🟢 = asked in almost every interview, 🔴 = senior-level.

## Linux & troubleshooting
1. 🟢 A server is slow. Walk me through how you investigate.
2. 🟢 What does load average mean? Is a load of 8 bad?
3. 🟢 `df` says the disk is full but `du` finds much less. Why?
4. What's the difference between a process and a thread? What's a zombie process?
5. 🟢 What happens when you run `kill PID`? And `kill -9 PID`?
6. What are file permissions `750` on a directory? What does the `x` bit mean for directories?
7. What is an inode? How can you run out of them?
8. 🟢 A systemd service won't start. What do you check?
9. Explain `free -h` output — why is "free" memory so low on a healthy server?
10. 🔴 What is the OOM killer and how do you find out it struck?

## Networking
11. 🟢 What happens when you type `https://example.com` into a browser and press Enter?
12. 🟢 TCP vs UDP — and an example where you'd use each.
13. 🟢 Connection refused vs connection timed out — what does each tell you?
14. How does DNS resolution work on a Linux host? Why might `dig` and `ping` disagree?
15. What's the difference between a load balancer at layer 4 and layer 7?
16. 🟢 What's a CIDR block? How many addresses are in a /24 and a /20?
17. What does TLS give you, and what does a client check in a certificate?
18. 🔴 What are the TIME_WAIT and CLOSE_WAIT states, and when do they become a problem?

## Git
19. 🟢 Merge vs rebase — when do you use each?
20. 🟢 You pushed a bad commit to `main`. How do you undo it?
21. How do you find which commit introduced a bug?
22. A secret was committed and pushed. What do you do?
23. What's a good branching strategy for a team deploying several times a day?

## Scripting (Bash & Python)
24. 🟢 What does `set -euo pipefail` do, and what are its gotchas?
25. How do you make a script safe to run twice (idempotent)?
26. `$@` vs `$*`, and why quoting matters.
27. When would you use Python instead of Bash?
28. How would you retry a flaky API call properly?

## Docker
29. 🟢 Container vs virtual machine?
30. 🟢 How do you make a Docker image small and secure?
31. `CMD` vs `ENTRYPOINT`?
32. What is a multi-stage build and why use it?
33. A container exits immediately after starting. How do you debug it?
34. How do containers isolate processes? (What's actually happening in the kernel?)

## Kubernetes
35. 🟢 Explain Pod, Deployment, Service and Ingress.
36. 🟢 A Pod is in CrashLoopBackOff. What do you do?
37. 🟢 Liveness vs readiness vs startup probes?
38. Requests vs limits — what happens when a container exceeds each?
39. How does a rolling update work, and how do you roll back?
40. ConfigMap vs Secret? Are Secrets secure by default?
41. 🔴 What happens, step by step, when you run `kubectl apply -f deployment.yaml`?
42. How do you give a Pod access to AWS without keys?

## Terraform & IaC
43. 🟢 What is Terraform state and why does it matter? Where do you keep it?
44. 🟢 `terraform plan` shows a resource will be destroyed and recreated. What do you do?
45. What's drift and how do you detect it?
46. Modules — when do you create one?
47. How do you manage multiple environments (dev/staging/prod)?
48. Terraform vs Ansible — what is each best at?
49. 🔴 How do you refactor (rename/move) resources without destroying them?

## CI/CD
50. 🟢 Continuous integration vs continuous delivery vs continuous deployment?
51. 🟢 Describe a good pipeline for a containerised service, from commit to production.
52. How do you keep secrets safe in a pipeline?
53. Blue/green vs canary vs rolling deployments?
54. What is GitOps?
55. 🔴 How do you secure the software supply chain?

## Monitoring & logging
56. 🟢 Metrics vs logs vs traces?
57. 🟢 What would you alert on for a web service? (What wouldn't you?)
58. What are SLIs, SLOs and error budgets?
59. Explain the RED and USE methods.
60. Why is high label cardinality a problem in Prometheus?
61. How do you centralise logs from 100 servers? What would you watch out for?
62. 🔴 What is a burn-rate alert and why is it better than a threshold alert?

## AWS & cloud
63. 🟢 Explain a VPC with public and private subnets. How do instances in a private subnet reach the internet?
64. 🟢 IAM user vs role? Why prefer roles?
65. Security group vs NACL?
66. How would you make a web app highly available on AWS?
67. S3 storage classes, versioning and lifecycle rules — when do you use them?
68. ECS vs EKS vs Lambda — how do you choose?
69. How do you control and reduce AWS costs?
70. 🔴 Design a multi-account AWS setup for a growing company.

## Incidents & culture
71. 🟢 Tell me about an incident you handled.
72. What is a blameless postmortem?
73. 🟢 What does "DevOps" mean to you?
74. How do you handle a disagreement about a technical decision?
75. How do you prioritise when everything is urgent?
