#!/usr/bin/env python3
servers = ["web-01", "web-02", "db-01", "cache-01"]

for number, server in enumerate(servers, start=1):
    note = " (database!)" if server.startswith("db") else ""
    print(f"{number}. {server}{note}")
