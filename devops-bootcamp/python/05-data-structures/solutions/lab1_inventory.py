#!/usr/bin/env python3
servers = ["web-01", "web-02", "db-01"]
servers.append("cache-01")
servers.remove("web-02")
servers.insert(0, "lb-01")
servers.sort()
print(f"{len(servers)} servers: {servers}")
