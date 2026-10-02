#!/usr/bin/env python3
class Service:
    def __init__(self, name: str, port: int):
        self.name = name
        self.port = port

    def health_check(self) -> bool:
        print(f"[{self.name}] checking TCP port {self.port}")
        return True


class NginxService(Service):
    def __init__(self, port: int = 80):
        super().__init__("nginx", port)

    def health_check(self) -> bool:
        print(f"[{self.name}] GET http://localhost:{self.port}/health")
        return True


class PostgresService(Service):
    def __init__(self, port: int = 5432):
        super().__init__("postgres", port)

    def health_check(self) -> bool:
        print(f"[{self.name}] running SELECT 1 on :{self.port}")
        return False  # pretend the DB is down


class RedisService(Service):
    def __init__(self, port: int = 6379):
        super().__init__("redis", port)

    def health_check(self) -> bool:
        print(f"[{self.name}] sending PING on :{self.port}")
        return True


if __name__ == "__main__":
    services = [NginxService(), PostgresService(), RedisService()]
    results = {s.name: s.health_check() for s in services}
    healthy = [n for n, ok in results.items() if ok]
    unhealthy = [n for n, ok in results.items() if not ok]
    print(f"Healthy: {healthy}  Unhealthy: {unhealthy}")
