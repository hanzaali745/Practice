#!/usr/bin/env python3
total = int(input("Uptime in seconds: "))
days = total // 86400
hours = (total % 86400) // 3600
minutes = (total % 3600) // 60
seconds = total % 60
print(f"{days} days, {hours} hours, {minutes} minutes, {seconds} seconds")
