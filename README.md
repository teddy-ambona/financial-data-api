# financial-data-api &middot; ![ci](https://github.com/teddy-ambona/financial-data-api/actions/workflows/ci.yml/badge.svg)

This repo is a template for dockerized flask applications(REST API). This simplified API exposes GET endpoints that allow you to pull stock prices and trading indicators. You will find the following implementation:

- Github Actions CICD
- Docker PostgreSQL DB setup for local testing
- Docker image build and distribution pattern
- Services configuration with Docker Compose
- Makefile template
- Flask blueprints
- Testing patterns
- Flask-SQLAlchemy implementation
- Dependency injection

<img src="./docs/img/architecture.png" width="700"/>

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose CLI plugin](https://docs.docker.com/compose/install/compose-plugin/)
- If running on windows: [Docker remote containers on WSL 2](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers)

> The API doesn't require python installed on your machine.

## Quickstart

Run the following commands to:

- Build the Docker image
- Run the app and db services
- Populate DB with TSLA and AMZN stock prices

```bash
make build up
```

Verify the API is running:

```bash
curl -I http://127.0.0.1:5000/_healthcheck
```

Get resampled data

```bash
$ curl -G -d 'interval=1' -d 'frequency=Annual' http://127.0.0.1:5000/stocks/time-series/AMZN
[
  {
    "close": 92.392,
    "high": 101.79,
    "low": 84.253,
    "open": 95.455,
    "period_start": "2019-01-01",
    "symbol": "AMZN",
    "volume": 8154332000
  },
  {
    "close": 162.8465,
    "high": 177.6125,
    "low": 81.3015,
    "open": 93.75,
    "period_start": "2020-01-01",
    "symbol": "AMZN",
    "volume": 24950814000
  },
  {
    "close": 166.717,
    "high": 188.654,
    "low": 144.05,
    "open": 163.5,
    "period_start": "2021-01-01",
    "symbol": "AMZN",
    "volume": 17076362000
  },
  {
    "close": 116.46,
    "high": 171.4,
    "low": 101.26,
    "open": 167.55,
    "period_start": "2022-01-01",
    "symbol": "AMZN",
    "volume": 10032250600
  }
]
```

## Project file structure

```text
.
├── .github
│   ├── workflow
│   │   └── cicd.yaml
├── config
│   ├── .yamllint
│   └── api_settings
│       ├── development
│       │   └── config.yaml
│       ├── local
│       │   └── config.yaml
│       ├── production
│       │   └── config.yaml
│       └── test
│           └── config.yaml
├── docs
│   └── img
│       ├── CICD.png
│       ├── architecture.png
│       └── four-phase-test.gif
├── src
│   ├── __init__.py
│   ├── app.py
│   ├── blueprints
│   │   ├── healthcheck.py
│   │   └── stocks.py
│   └── models.py
├── tests
│   ├── __init__.py
│   ├── conftest.py
│   ├── integration
│   │   ├── test_data
│   │   │   └── stocks_ohlcv.csv
│   │   ├── __init__.py
│   │   ├── test_app.py
│   │   └── test_stocks.py
│   └── unit
│       ├── __init__.py
│       └── test_helpers.py
├── .dockerignore
├── .gitignore
├── docker-compose.yaml
├── Dockerfile
├── Makefile
├── README.md
├── requirements.in
├── requirements.txt
```

## CICD overview

<img src="./docs/img/CICD.png" width="700"/>
<br></br>

- **yamllint:** Lints yaml files in the repo
- **flake8:** Lints .py files in the repo
- **pydocstyle:** Checks compliance with Python docstring conventions
- **safety:** python packages vulnerabilities scanner
- **image-misconfiguration:** Detect configuration issues in Dockerfile(Trivy)
- **build:** Build Docker image and push it to the pipeline artifacts
- **image-vulnerabilities:** Image vulnerablities scanner(Trivy)
- **unit-tests:** Test the smallest piece of code(functions) that can be isolated
- **integration-tests:** Series of tests which call the API
- **push-to-registry:** Push the Docker image to Docker Hub

> Note that the last job should be skipped when running the pipeline locally.
This is ensured using `if: ${{ !env.ACT }}` in the `push-to-registry` job.
Running this locally means there will be a conflicting image tag when the Github Actions CICD will try and run it a second time.

## Running the CICD pipeline locally

Install [act](https://github.com/nektos/act) to run the jobs on your local machine.

Example:

```bash
act --secret-file secrets.txt --artifact-server-path /tmp/artifacts  # Run the full CICD pipeline
act -j pydocstyle --secret-file secrets.txt --artifact-server-path /tmp/artifacts # Run specific job
```

In `secrets.txt`:

```bash
GITHUB_TOKEN=<YOUR_PAT_TOKEN>
DOCKERHUB_USERNAME=<YOUR_DOCKERHUB_USERNAME>
DOCKERHUB_TOKEN=<YOUR_DOCKERHUB_TOKEN>
```

`--artifact-server-path` has to be specified as the workflow is using `actions/upload-artifact` and `actions/download-artifact`([cf issue](https://github.com/nektos/act/issues/329#issuecomment-1187246629))

Optionally you could also run pipeline jobs using the Makefile directly.

Example:

```bash
make pydocstyle
make tests
make run-cicd  # Run the full CICD pipeline without pushing to Docker Hub
```

## Docker image build pattern

The requirements are:

- A dev image should be pushed to [Docker Hub](https://hub.docker.com/r/tambona29/financial-data-api/tags) everytime a `git push` is made. That allows end-to-end testing in dev environment. I chose Docker Hub over AWS as Docker Hub is still the best choice for distributing software publicly.

- Leverage pipeline artifacts to avoid rebuilding the image from scratch across jobs. Also pass image tag variables between jobs/steps using the output functionality to keep the code DRY.

- The image tag should follow [SemVer specifications](https://semver.org/) which is `MAJOR.MINOR.PATCH-<BRANCH NAME>.dev.<COMMIT SHA>` for dev versions and `MAJOR.MINOR.PATCH` for production use.

### SemVer2

|   Branch  | Commit # | Image Version | Image Tag  |
|:---------:|:--------:|:-------------:|:----------:|
| feature-1 |     1    |      1.0.0    | 1.0.0-feature-1.dev.b1d7ba7fa0c6a14041caaaf4025f6cebb924cb0f |
| feature-1 |     2    |      1.0.0    |   1.0.0-feature-1.dev.256e60e615e89332c5f602939463500c1be5d90a |
|   main    |     5     |      1.0.0    |    1.0.0 |

> The [docker/metadata-action@v4](https://github.com/docker/metadata-action#semver) task can automate this but it requires using git tags which can be a bit cumbersome as it requires an update for each commit. So I preferred reimplementing something straightforward that uses the git branch name and commit SHA to form the image tag.

## Testing framework

### [GIVEN-WHEN-THEN](https://martinfowler.com/bliki/GivenWhenThen.html) (Martin Fowler)

**GIVEN** - Describes the state of the world before you begin the behavior you're specifying in this scenario. You can think of it as the pre-conditions to the test.

**WHEN** - Behavior that you're specifying.

**THEN** - Changes you expect due to the specified behavior.

### [Four-Phase Test](http://xunitpatterns.com/Four%20Phase%20Test.html) (Gerard Meszaros)

<img src="./docs/img/four-phase-test.png" width="700"/>

*(image from [Four-Phase Test](http://xunitpatterns.com/Four%20Phase%20Test.html))*
<br></br>

For integration testing, the *Setup* phase consists in truncating and repopulating the DB.
