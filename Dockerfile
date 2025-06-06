# ======= Build image =======
FROM public.ecr.aws/docker/library/python:3.9.21-bookworm AS build-image

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./requirements.txt .

ENV VIRTUAL_ENV=/app/.venv
RUN python -m venv $VIRTUAL_ENV

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python -m pip install --upgrade pip \
    && python -m pip install -r requirements.txt

# ======= Production image =======
FROM public.ecr.aws/docker/library/python:3.9.21-slim-bookworm AS runtime-image

LABEL org.opencontainers.image.source=https://github.com/pvital/simple-django
LABEL org.opencontainers.image.description="Simple Django container"
LABEL org.opencontainers.image.licenses=MIT

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE 1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libxml2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the project into the container
ENV VIRTUAL_ENV=/app/.venv

WORKDIR /app

COPY ./mysite ./mysite
COPY ./simple_app ./simple_app
COPY ./db.sqlite3 ./
COPY ./manage.py ./
COPY ./uwsgi.ini ./

COPY --from=build-image $VIRTUAL_ENV .venv

# Creates a non-root user and adds permission to access the /app folder
RUN addgroup --gid 1000 admin \
    && adduser --uid 1002 --gid 1000 --disabled-password user \
    && chown -R user:admin /app
USER user

# Set up environment variables
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE 8000

# Run the application
CMD ["uwsgi", "--ini", "uwsgi.ini", "--http", "0.0.0.0:8000"]