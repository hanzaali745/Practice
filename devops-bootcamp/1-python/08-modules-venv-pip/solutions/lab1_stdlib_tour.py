#!/usr/bin/env python3
import datetime
import getpass
import os
import platform
import socket

print("User:     ", getpass.getuser())
print("Hostname: ", socket.gethostname())
print("OS:       ", platform.system(), platform.release())
print("Python:   ", platform.python_version())
print("Time:     ", datetime.datetime.now().isoformat(timespec="seconds"))
print("Home:     ", os.path.expanduser("~"))
