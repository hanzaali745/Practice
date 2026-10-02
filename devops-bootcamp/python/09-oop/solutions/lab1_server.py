#!/usr/bin/env python3
class Server:
    def __init__(self, hostname: str, ip: str, env: str = "dev"):
        self.hostname = hostname
        self.ip = ip
        self.env = env
        self.running = False

    def start(self) -> None:
        self.running = True

    def stop(self) -> None:
        self.running = False

    def restart(self) -> None:
        self.stop()
        self.start()

    def __str__(self) -> str:
        state = "RUNNING" if self.running else "STOPPED"
        return f"{self.hostname} [{self.env}] {self.ip} - {state}"


if __name__ == "__main__":
    web = Server("web-01", "10.0.0.1", "prod")
    print(web)
    web.start()
    print(web)
    web.restart()
    print(web)
