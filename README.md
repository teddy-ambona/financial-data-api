This repo is a template for dockerized flask applications(REST API). You will find the following implementation:

- Github Actions CICD
- Docker PostgreSQL DB setup for local testing
- Docker image build pattern
- Services configuration with Docker Compose
- Makefile template
- Flask blueprints
- Testing patterns
- Flask-SQLAlchemy implementation
- Dependency injection


# Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose CLI plugin](https://docs.docker.com/compose/install/compose-plugin/)
- If running on windows: [Docker remote containers on WSL 2](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers)
- Database passwords should be stored under ~/.pgpass.
  For running the tests you will need to add this line to the file: `localhost:5432:*:postgres:postgres`

> The API doesn't require python installed on your machine.

# Quickstart

Run the following commands to build the Docker image and run the app and db services:

```
make build up
```

Verify the API is running:

```
curl -I http://127.0.0.1:5000/_healthcheck
```

# Project file structure

```
├── .github
│   ├── workflow
│   │   └── cicd.yaml
├── config
│   ├── development
│   │   └── config.yaml
│   ├── local
│   │   └── config.yaml
│   ├── production
│   │   └── config.yaml
│   └── test
│       └── config.yaml
├── docs
│   └── img
│       └── CICD.png
├── src
│   ├── __init__.py
│   ├── app.py
│   ├── healthcheck.py
│   ├── models.py
│   └── stocks.py
├── tests
│   ├── __init__.py
│   └── integration
│       ├── __init__.py
│       ├── test_app.py
│       ├── test_data
│       │   └── stocks_ohlcv.csv
│       └── test_stocks.py
├── .gitignore
├── .yamllint
├── docker-compose.yaml
├── Dockerfile
├── Makefile
├── README.md
├── requirements.in
├── requirements.txt



```

# CICD overview

<img src="./docs/img/CICD.png" width="700"/>
<br></br>

- **yamllint:** Lints yaml files in the repo
- **flake8:** Lints .py files in the repo
- **pydocstyle:** Checks compliance with Python docstring conventions
- **safety:** python packages vulnerabilities scanner
- **image-misconfiguration:** Detect configuration issues in Dockerfile(Trivy)
- **build:** Build Docker image
- **image-vulnerabilities:** Image vulnerablities scanner(Trivy)
- **integration-tests:** Series of tests which call the API

# Running the CICD pipeline locally

Install [act](https://github.com/nektos/act) to run the jobs on your local machine.

Example:
```
act  # Run the full CICD pipeline
act -j pydocstyle  # Run specific job
```
Optionally you could also use the Makefile directly

Example:
```
make pydocstyle
make setup-db integration-tests
```
