.PHONY: build integration-tests run-app flake8 pydocstyle yamllint pip-compile safety up down tests

ENV = test
IMAGE_TAG = flask-app:latest
DRUN = docker run --rm
DBASH = $(DRUN) -u root -v ${PWD}:/foo -w="/foo" python bash -c 

build:
	docker build -t flask-app .

up:
	export IMAGE_TAG=${IMAGE_TAG} && \
	docker-compose -f docker-compose.yaml up

down:
	docker-compose down

setup-db:
	docker-compose -f docker-compose.yaml up -d postgres-db
	sleep 3  # Wait for DB to be up and running

integration-tests:
	$(DRUN) -e ENVIRONMENT=${ENV} --entrypoint="" --network host ${IMAGE_TAG} bash -c \
	"python -m unittest discover -s tests/integration/"

tests:
	make setup-db
	make integration-tests

flake8:
	# The GitHub editor is 127 chars wide
	$(DBASH) \
	"pip install -U pip && \
	pip install flake8 && \
	flake8 . --extend-ignore=F405 --max-line-length=127"

pydocstyle:
	$(DBASH) \
	"pip install -U pip && \
	pip install pydocstyle && \
	pydocstyle --convention=numpy --add-ignore=D100,D101,D102,D103,D104,D105,D106,D107 src tests"

yamllint:
	$(DBASH) \
	"pip install -U pip && \
	pip install yamllint && \
	yamllint -c config/.yamllint ."

pip-compile:
	$(DBASH) \
	"pip install -U pip && \
	pip install pip-tools && \
	pip-compile"

safety:
	$(DBASH) \
	"pip install -U pip && pip install safety && safety check -r requirements.txt"
