# Lab 3 — dependency layer BEFORE the code, so code changes don't reinstall packages
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
CMD ["python3", "app.py"]
