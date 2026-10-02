#!/usr/bin/env python3
for build in range(1, 31):
    if build % 3 == 0 and build % 5 == 0:
        print("Deploy+Test")
    elif build % 3 == 0:
        print("Deploy")
    elif build % 5 == 0:
        print("Test")
    else:
        print(build)
