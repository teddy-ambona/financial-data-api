FROM python:3.8.13

RUN groupadd -r user && useradd -r -g user app

# Upgrade packages to fix vulnerabilities found with Trivy
RUN apt-get update -y && apt-get install -y \
    openssl \
    libssl-dev \
    libssl1.1

RUN pip install pip -U && pip install pip-tools

RUN mkdir /app && chown -R app /app

WORKDIR /app

# Install requirements.txt in new instruction to benefit from the layer caching system.
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY config ./config/
COPY src ./src/
COPY tests ./tests/

# Using non-root user to reduce vulnerabilities
USER app

ENTRYPOINT ["python", "-m", "src.app"]
