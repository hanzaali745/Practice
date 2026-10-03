# Lab 2 — containerise demo-app
FROM python:3.12-slim

ARG VERSION=dev
LABEL org.opencontainers.image.title="demo-app" \
      org.opencontainers.image.version="${VERSION}"

WORKDIR /app
COPY app.py .

ENV PORT=8000 \
    APP_VERSION=${VERSION} \
    PYTHONUNBUFFERED=1

EXPOSE 8000
CMD ["python3", "app.py"]
