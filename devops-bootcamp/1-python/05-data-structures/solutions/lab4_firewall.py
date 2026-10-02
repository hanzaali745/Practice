#!/usr/bin/env python3
allowed = {22, 80, 443}
servers = {
    "web-01": {22, 80, 443},
    "web-02": {22, 80, 443, 8080},
    "db-01": {22, 5432},
}

for name, ports in servers.items():
    unexpected = ports - allowed
    missing = allowed - ports
    print(f"{name}: unexpected={sorted(unexpected) or 'none'} missing={sorted(missing) or 'none'}")
