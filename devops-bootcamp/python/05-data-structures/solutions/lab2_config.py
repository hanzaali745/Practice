#!/usr/bin/env python3
config = {"app_name": "api", "port": 8080, "debug": False, "replicas": 3}

for key, value in config.items():
    print(f"{key}: {value}")

print("log_level:", config.get("log_level", "INFO"))
config["replicas"] = 5
print("replicas now:", config["replicas"])
