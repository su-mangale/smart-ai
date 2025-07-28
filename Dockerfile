# Build stage - Install dependencies and compile
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Set environment variables for build stage
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pip-tools for dependency resolution
RUN pip install pip-tools

# Copy requirements files
COPY requirements.in .
COPY requirements.txt .

# Generate pinned requirements if not exists, or use existing
RUN if [ ! -f requirements.txt ] || [ requirements.in -nt requirements.txt ]; then \
        pip-compile requirements.in; \
    fi

# Install dependencies in user directory
RUN pip install --user --no-cache-dir -r requirements.txt

# Production Stage - Distroless for minimal attack surface
FROM gcr.io/distroless/python3-debian11 AS production

# Set working directory
WORKDIR /app

# Set environment variables for production
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production \
    FLASK_APP=run.py \
    PYTHONPATH=/app

# Copy Python packages from builder stage
COPY --from=builder /root/.local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /root/.local/bin /usr/local/bin

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run the application directly with Python
# Note: Distroless doesn't have shell, so we use exec form
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
