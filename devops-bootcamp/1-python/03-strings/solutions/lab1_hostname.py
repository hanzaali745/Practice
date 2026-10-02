#!/usr/bin/env python3
raw = "   PROD_Web_Server_01  "
clean = raw.strip().lower().replace("_", "-")
print(clean)  # prod-web-server-01
