# Module 09 — Object-Oriented Python 🟡

## 🎯 Objectives
- Understand **classes** (blueprints) and **objects** (instances)
- Use `__init__`, attributes, methods, and `self`
- Use inheritance and method overriding
- Use `@property`, `@classmethod`, `__str__`/`__repr__`
- Use `@dataclass` for clean data models

## 🧠 Why DevOps engineers care
Real tools model real things: a `Server`, a `Deployment`, a `HealthCheck`, a `Backup`.
Libraries you'll use daily (`boto3`, `requests`, `kubernetes`) are all class-based —
`requests.Session()`, `boto3.client("s3")`. Understanding OOP lets you read and extend them.

---

## 📖 Lesson 9.1 — Class & object

```python
class Server:
    """A server in our infrastructure."""

    def __init__(self, hostname: str, ip: str, cpu_cores: int = 2):
        # __init__ runs when you create an object. `self` = this specific object.
        self.hostname = hostname
        self.ip = ip
        self.cpu_cores = cpu_cores
        self.running = False

    def start(self) -> None:
        self.running = True
        print(f"{self.hostname} started")

    def status(self) -> str:
        return "RUNNING" if self.running else "STOPPED"


web = Server("web-01", "10.0.1.10", cpu_cores=4)   # create an object (instance)
db = Server("db-01", "10.0.2.10")

web.start()
print(web.hostname, web.status())   # web-01 RUNNING
print(db.hostname, db.status())     # db-01 STOPPED
```

**Class** = blueprint (cookie cutter). **Object** = a thing built from it (a cookie).

## 📖 Lesson 9.2 — Class attributes vs instance attributes

```python
class Server:
    count = 0                       # shared by ALL servers (class attribute)

    def __init__(self, hostname):
        self.hostname = hostname    # unique per server (instance attribute)
        Server.count += 1

Server("a"); Server("b")
print(Server.count)                 # 2
```

## 📖 Lesson 9.3 — Nice printing: `__str__` and `__repr__`

```python
class Server:
    def __init__(self, hostname, ip):
        self.hostname, self.ip = hostname, ip

    def __str__(self):              # for humans: print(obj)
        return f"{self.hostname} ({self.ip})"

    def __repr__(self):             # for developers: debugging, lists
        return f"Server(hostname={self.hostname!r}, ip={self.ip!r})"

s = Server("web-01", "10.0.0.1")
print(s)          # web-01 (10.0.0.1)
print([s])        # [Server(hostname='web-01', ip='10.0.0.1')]
```

## 📖 Lesson 9.4 — Inheritance

A child class **reuses** everything from the parent and can add or override behaviour.

```python
class Server:
    def __init__(self, hostname):
        self.hostname = hostname

    def health_check(self) -> bool:
        print(f"{self.hostname}: generic ping")
        return True


class WebServer(Server):
    def __init__(self, hostname, port=80):
        super().__init__(hostname)        # run the parent's __init__
        self.port = port

    def health_check(self) -> bool:       # override
        print(f"{self.hostname}: HTTP GET :{self.port}/health")
        return True


class DatabaseServer(Server):
    def health_check(self) -> bool:
        print(f"{self.hostname}: SELECT 1")
        return True


fleet = [WebServer("web-01", 8080), DatabaseServer("db-01"), Server("misc-01")]
for server in fleet:
    server.health_check()    # each one does its own thing = "polymorphism"
```

## 📖 Lesson 9.5 — `@property`, `@classmethod`, `@staticmethod`

```python
class Disk:
    def __init__(self, total_gb: float, used_gb: float):
        self.total_gb = total_gb
        self.used_gb = used_gb

    @property
    def percent_used(self) -> float:       # accessed like an attribute, computed live
        return self.used_gb / self.total_gb * 100

    @classmethod
    def from_string(cls, text: str) -> "Disk":   # alternative constructor
        total, used = text.split("/")
        return cls(float(total), float(used))

    @staticmethod
    def gb_to_mb(gb: float) -> float:      # utility, doesn't need self or cls
        return gb * 1024


d = Disk.from_string("500/375")
print(f"{d.percent_used:.0f}%")           # 75%  (no parentheses!)
```

## 📖 Lesson 9.6 — Dataclasses (modern & clean)

For classes that mainly **hold data**, `@dataclass` writes `__init__`, `__repr__` and `__eq__` for you:

```python
from dataclasses import dataclass, field

@dataclass
class Deployment:
    app: str
    version: str
    env: str = "dev"
    replicas: int = 1
    tags: list[str] = field(default_factory=list)   # safe mutable default

    def describe(self) -> str:
        return f"{self.app}:{self.version} -> {self.env} x{self.replicas}"

d = Deployment("api", "1.4.2", env="prod", replicas=3)
print(d)               # Deployment(app='api', version='1.4.2', env='prod', replicas=3, tags=[])
print(d.describe())
```

## 📖 Lesson 9.7 — When to use OOP?
- ✅ You have **data + behaviour** that belong together (a Server that can `restart()`)
- ✅ You have several **variants** of a thing (Web/DB/Cache servers)
- ❌ A 30-line script — plain functions are fine. Don't over-engineer!

## ⚠️ Common mistakes
- Forgetting `self` as the first method parameter
- Forgetting `super().__init__(...)` in a child class
- Using a mutable default (`tags=[]`) in a dataclass — use `field(default_factory=list)`
- Building deep inheritance trees — prefer simple, flat designs

---

## 🧪 Labs

### Lab 1 ⭐ — Server class
Create `Server` with `hostname`, `ip`, `env`, and methods `start()`, `stop()`, `restart()`,
and a `__str__` like `web-01 [prod] 10.0.0.1 - RUNNING`.

### Lab 2 ⭐⭐ — Service fleet with inheritance
Create a base `Service(name, port)` with `health_check()` returning a bool.
Create `NginxService`, `PostgresService`, `RedisService` that override `health_check()`
(just print what they'd check, return `True`/`False`). Loop over a list and print a summary
of healthy/unhealthy services.

### Lab 3 ⭐⭐ — Disk with properties
Create `Disk(mount, total_gb, used_gb)` with properties `free_gb`, `percent_used`,
and `status` (`OK` / `WARN` ≥ 80 / `CRIT` ≥ 90). Add `from_df_line()` classmethod that parses:
`"/dev/sda1  500G  455G  45G  91% /"`.

### Lab 4 ⭐⭐⭐ — Deployment pipeline
Using `@dataclass`, model `Deployment(app, version, env, replicas)` and a `Pipeline` class with:
- `add(deployment)`
- `run(dry_run=True)` — "deploys" in order dev → staging → prod (sort by env order!)
- If a deployment to `prod` has `replicas < 2`, raise a custom `DeploymentError`
- Keep a history list of what ran and print it at the end

---

## ✅ Checkpoint
- [ ] I can explain class vs object and what `self` is
- [ ] I can inherit and override methods, using `super()`
- [ ] I know when a `@dataclass` is a better fit

👉 Next: [Module 10 — System Automation](../10-system-automation/README.md)
