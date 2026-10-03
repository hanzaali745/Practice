# A deliberately BROKEN release, for practising rollbacks:
# the app starts, but its healthcheck fails (wrong path), so the deploy must be rolled back.
ARG BASE
FROM ${BASE}
HEALTHCHECK --interval=3s --timeout=2s --start-period=2s --retries=2 \
  CMD ["python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/does-not-exist', timeout=2)"]
