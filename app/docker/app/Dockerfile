# Fetch a compatible version with 3.10.* including the latest patch release
FROM python:3.10

RUN groupadd -r user && useradd -r -g user app

RUN pip install pip -U && pip install pip-tools

RUN mkdir -v /app && chown -R app /app

# Create log directory for gunicorn
RUN mkdir -pv /var/log/gunicorn/ && chown -R app /var/log/gunicorn/

# Create PID directory for gunicorn
RUN mkdir -pv /var/run/gunicorn/ && chown -R app /var/run/gunicorn/

WORKDIR /app

# Install requirements.txt in new instruction to benefit from the layer caching system.
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY config/api_settings ./settings
COPY src ./src/
COPY tests ./tests/

# Using non-root user to reduce vulnerabilities
USER app

# Use Gunicorn as production server
ENTRYPOINT ["gunicorn", "-c", "settings/gunicorn.py", "src.app:create_app()"]
