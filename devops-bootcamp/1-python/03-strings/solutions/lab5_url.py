#!/usr/bin/env python3
url = "https://api.example.com:8443/v1/health?verbose=true"

scheme, rest = url.split("://", 1)
rest, query = rest.split("?", 1)
host_port, path = rest.split("/", 1)
host, port = host_port.split(":")
path = "/" + path

print(f"scheme={scheme} host={host} port={port} path={path} query={query}")
