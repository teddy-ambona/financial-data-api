.PHONY: build integration-tests run-app flake8 pydocstyle yamllint pip-compile safety up down tests populate-db

ENV = test
IMAGE_TAG = flask-app:latest
DRUN = docker run --rm -e ENVIRONMENT=${ENV}
DBASH = $(DRUN) -u root -v ${PWD}:/foo -w="/foo" python bash -c 

# Build app Docker image
build-app:
	docker build -f docker/app/Dockerfile -t flask-app .

# Build Nginx (reverse proxy) Docker image
build-nginx:
	docker build -f docker/nginx/Dockerfile -t flask-app-nginx .

# To see logs just remove the -d arg that runs the app as a daemon container
up:
	export IMAGE_TAG=${IMAGE_TAG} \
	&& make setup-db \
	&& make aws-secrets-manager \
	&& make populate-db \
	&& docker-compose -f docker/docker-compose.yaml up -d nginx

down:
	docker-compose -f docker/docker-compose.yaml down

setup-db:
	docker-compose -f docker/docker-compose.yaml up -d postgres-db
	sleep 3  # Wait for DB to be up and running

teardown-db:
	docker-compose -f docker/docker-compose.yaml rm -s -v -f postgres-db

# Populate local DB with the csvs in tests/integation/test_data/
populate-db:
	# Populate local database with test csvs
	$(DRUN) \
	-e AWS_ACCESS_KEY_ID=test \
	-e AWS_SECRET_ACCESS_KEY=test \
	-e AWS_DEFAULT_REGION=us-east-1 \
	--entrypoint="" \
	--network host \
	${IMAGE_TAG} python -c \
	"from tests.conftest import populate_db_for_local_testing; populate_db_for_local_testing();"

# Start localstack and create a secret called "db/credentials"
aws-secrets-manager:
	docker-compose -f docker/docker-compose.yaml up -d localstack
	docker run --rm --entrypoint="" --network host localstack/localstack bash -c \
	"awslocal secretsmanager create-secret \
	--name db/credentials \
	--secret-string '{\"DB_USERNAME\":\"postgres\",\"DB_PASSWORD\":\"postgres\"}'"

# Run unit tests
unit-tests:
	$(DRUN) --entrypoint="" ${IMAGE_TAG} bash -c \
	"python -m pytest -v --cov=src tests/unit/"

# Run integation tests
integration-tests:
	make setup-db
	make aws-secrets-manager
	$(DRUN) \
	-e AWS_ACCESS_KEY_ID=test \
	-e AWS_SECRET_ACCESS_KEY=test \
	-e AWS_DEFAULT_REGION=us-east-1 \
	--entrypoint="" \
	--network host ${IMAGE_TAG} bash -c \
	"python -m pytest -v --cov=src tests/integration/"
	make down

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
	yamllint ."

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

# Trivy image-vulnerabilities
image-vulnerabilities:
	docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${HOME}/Library/Caches:/root/.cache/ \
	aquasec/trivy image ${IMAGE_TAG} \
	--format table \
	--vuln-type library \
	--severity CRITICAL,HIGH \
	--ignore-unfixed \
	--exit-code 1
