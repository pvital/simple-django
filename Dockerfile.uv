FROM public.ecr.aws/docker/library/python:3.9.21-slim-bookworm

LABEL org.opencontainers.image.source=https://github.com/pvital/simple-flask
LABEL org.opencontainers.image.description="Simple Flask container"
LABEL org.opencontainers.image.licenses=MIT

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE 1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y curl procps build-essential python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy the project into the container
ADD . /app
WORKDIR /app

# Creates a non-root user and adds permission to access the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Sync the project into a new environment, using the frozen lockfile
RUN uv sync --frozen

EXPOSE 8000

ENV INSTANA_DEBUG=True
ENV INSTANA_SERVICE_NAME=simple-django-pvital

# Run the application
ENTRYPOINT ["uv", "run"]
CMD ["uwsgi", "--ini", "uwsgi.ini", "--http", "0.0.0.0:8000"]