#!/usr/bin/env python3
image = "registry.example.com/team/api-service:v2.3.1"

name, tag = image.rsplit(":", 1)          # split from the right, once
registry, repository = name.split("/", 1)

print("registry:  ", registry)
print("repository:", repository)
print("tag:       ", tag)
