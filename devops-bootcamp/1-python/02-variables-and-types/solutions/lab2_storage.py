#!/usr/bin/env python3
mb = float(input("Size in MB: "))
gb = mb / 1024
tb = gb / 1024
print(f"{mb} MB = {gb:.2f} GB = {tb:.2f} TB")
