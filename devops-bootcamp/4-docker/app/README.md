# demo-app

The sample service used in the Docker and Kubernetes tracks. Standard library only.

```bash
python3 app.py                         # http://localhost:8000
curl localhost:8000/ ; curl localhost:8000/health ; curl localhost:8000/visits
python3 -m pytest -q                   # tests
```

| Env var | Default | Meaning |
|---------|---------|---------|
| `PORT` | `8000` | listen port |
| `APP_VERSION` | `1.0.0` | reported version |
| `APP_MESSAGE` | `Hello from demo-app` | greeting |
| `REDIS_HOST` / `REDIS_PORT` | unset / `6379` | store `/visits` in Redis |
