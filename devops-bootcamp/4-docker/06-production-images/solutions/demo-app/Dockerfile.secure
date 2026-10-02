# Lab 1 — production-ready demo-app image
FROM python:3.12-slim

ARG VERSION=dev
ARG GIT_SHA=unknown
LABEL org.opencontainers.image.title="demo-app" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.source="https://github.com/hanzaali745/Practice"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    APP_VERSION=${VERSION}

# A dedicated, numeric, non-root user (Kubernetes runAsNonRoot can verify numeric UIDs)
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY --chown=root:root --chmod=0644 app.py .

USER 10001
EXPOSE 8000

# python3 is already in the image, so no curl needed for the healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD ["python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=2)"]

CMD ["python3", "app.py"]
