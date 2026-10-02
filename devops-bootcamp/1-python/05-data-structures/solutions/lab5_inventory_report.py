#!/usr/bin/env python3
inventory = [
    {"name": "web-01", "env": "prod", "role": "web", "cpu": 45, "mem": 70},
    {"name": "web-02", "env": "prod", "role": "web", "cpu": 91, "mem": 85},
    {"name": "db-01", "env": "prod", "role": "db", "cpu": 66, "mem": 93},
    {"name": "web-03", "env": "staging", "role": "web", "cpu": 20, "mem": 30},
    {"name": "db-02", "env": "staging", "role": "db", "cpu": 10, "mem": 40},
]

# 1. Group by environment
by_env = {}
for host in inventory:
    by_env.setdefault(host["env"], []).append(host["name"])
print("By env:", by_env)

# 2. Hot servers
hot = [h["name"] for h in inventory if h["cpu"] > 90 or h["mem"] > 90]
print("Hot servers:", hot)

# 3. Average CPU per role
cpu_per_role = {}
for host in inventory:
    cpu_per_role.setdefault(host["role"], []).append(host["cpu"])
for role, values in cpu_per_role.items():
    print(f"Avg CPU for {role}: {sum(values) / len(values):.1f}%")

# 4. Unique roles
print("Roles:", {h["role"] for h in inventory})
