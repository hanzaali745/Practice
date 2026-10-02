#!/usr/bin/env python3
running = False

while True:
    command = input("Command (start/stop/status/quit): ").strip().lower()
    match command:
        case "start":
            running = True
            print("Service started")
        case "stop":
            running = False
            print("Service stopped")
        case "status":
            print("Service is", "RUNNING" if running else "STOPPED")
        case "quit":
            print("Bye!")
            break
        case _:
            print("Unknown command. Use: start, stop, status, quit")
