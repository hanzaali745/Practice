# Lab 4: docker build -t devopskit . && docker run --rm devopskit
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY devopskit/ devopskit/
COPY main.py check_deps.py ./
CMD ["python", "main.py"]
