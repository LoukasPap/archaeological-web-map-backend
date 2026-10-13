FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install dependencies first so this layer is cached until requirements change
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Run as an unprivileged user
RUN useradd --system --no-create-home appuser
USER appuser

EXPOSE 8000

# Behind a reverse proxy: trust the forwarded headers so redirects use the public host.
# Configuration (MONGODB_URI, MONGODB_DB, ORIGINS, JWT_SECRET, ...) comes from environment variables.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]
