# demo-app — CI/CD lab repository

This folder is the **starter project** for Phase 8 (CI/CD). You copy it into a **new GitHub repository of your own**,
because GitHub Actions only runs workflows from `.github/workflows/` at the root of a repository.

```bash
cd ~/Practice/devops-bootcamp/8-cicd
./new_lab_repo.sh ~/cicd-lab           # copies this folder, git init, first commit
cd ~/cicd-lab
# create an EMPTY repo called cicd-lab on github.com (no README), then:
git remote add origin git@github.com:<you>/cicd-lab.git
git push -u origin main
```

| Path | What |
|------|------|
| `app/app.py` | demo-app (the same app as Phases 4–7) |
| `tests/test_app.py` | unit tests — `python3 -m pytest -q` |
| `tests/test_integration.py` | needs Redis: `REDIS_HOST=127.0.0.1 python3 -m pytest -q` |
| `requirements-dev.txt` | pytest + ruff (pinned) |
| `Dockerfile` | the hardened image from Docker Module 06 |
| `deploy/k8s/` | Deployment + Service + `kustomization.yaml` (CI sets the image tag here) |
| `scripts/smoke_test.sh` | `smoke_test.sh URL [VERSION]` — post-deploy check |

Run everything locally first:
```bash
python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements-dev.txt
ruff check . && python3 -m pytest -q
docker build -t demo-app:dev --build-arg VERSION=dev .
```
