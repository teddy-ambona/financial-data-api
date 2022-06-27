FROM python:3.8.3

RUN pip install pip -U && pip install pip-tools

RUN mkdir /app

WORKDIR /app

# Install requirements.txt in new instruction to benefit from the layer caching system.
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY config ./config/
COPY src ./src/
COPY test ./test/
