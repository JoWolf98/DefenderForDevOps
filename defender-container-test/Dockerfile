FROM python:3.9.0-slim-buster

LABEL org.opencontainers.image.source=https://github.com/JoWolf98/DefenderForDevOps
LABEL org.opencontainers.image.title=defender-container-test
LABEL org.opencontainers.image.description="Defender for Cloud container test application"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

USER 65532:65532

CMD ["python", "app.py"]
