#!/usr/bin/env python3
hostname = "web-01"
ip_address = "10.0.1.15"
cpu_cores = 4
ram_gb = 16.0
is_production = True

for value in (hostname, ip_address, cpu_cores, ram_gb, is_production):
    print(value, "->", type(value))
