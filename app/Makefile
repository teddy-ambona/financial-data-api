.PHONY: build integration-tests run-app flake8 pydocstyle yamllint pip-compile safety up down tests populate-db

ENV = test
DB_PASSWORD=postgres
IMAGE_TAG = flask-app:latest
DRUN = docker run --rm
DBASH = $(DRUN) -u root -v ${PWD}:/foo -w="/foo" python bash -c 

# Build Docker image
build:
	docker build -t flask-app .

up:
	export IMAGE_TAG=${IMAGE_TAG} && \
	make setup-db && \
	make populate-db && \
	docker-compose -f docker-compose.yaml up -d flask-app

down:
	docker-compose down

setup-db:
	docker-compose -f docker-compose.yaml up -d postgres-db
	sleep 3  # Wait for DB to be up and running

teardown-db:
	docker-compose -f docker-compose.yaml rm -s -v -f postgres-db

# Populate local DB with the csvs in tests/integation/test_data/
populate-db:
	# Populate local database with test csvs
	$(DRUN) -e ENVIRONMENT=${ENV} -e DB_PASSWORD=${DB_PASSWORD} --entrypoint="" --network host ${IMAGE_TAG} python -c \
	"from tests.conftest import populate_db_for_local_testing; populate_db_for_local_testing();"

# Run unit tests
unit-tests:
	$(DRUN) -e ENVIRONMENT=${ENV} --entrypoint="" ${IMAGE_TAG} bash -c \
	"python -m pytest -v --cov=src tests/unit/"

# Run integation tests
integration-tests:
	make setup-db
	$(DRUN) -e ENVIRONMENT=${ENV} -e DB_PASSWORD=${DB_PASSWORD} --entrypoint="" --network host ${IMAGE_TAG} bash -c \
	"python -m pytest -v --cov=src tests/integration/"
	make teardown-db

# Run full test suite
tests:
	make unit-tests
	make integration-tests

# Lints .py files in the repo
flake8:
	# The GitHub editor is 127 chars wide
	$(DBASH) \
	"pip install -U pip && \
	pip install flake8 && \
	flake8 . --extend-ignore=F405 --max-line-length=127"

# Checks compliance with Python docstring conventions
pydocstyle:
	$(DBASH) \
	"pip install -U pip && \
	pip install pydocstyle && \
	pydocstyle --convention=numpy --add-ignore=D100,D101,D102,D103,D104,D105,D106,D107 src tests"

# Lints yaml files in the repo
yamllint:
	$(DBASH) \
	"pip install -U pip && \
	pip install yamllint && \
	yamllint -c config/.yamllint ."

# Auto-generate requirements.txt based on requirements.in
pip-compile:
	$(DBASH) \
	"pip install -U pip && \
	pip install pip-tools && \
	pip-compile"

# Python packages vulnerabilities scanner
safety:
	$(DBASH) \
	"pip install -U pip && pip install safety && safety check -r requirements.txt"
