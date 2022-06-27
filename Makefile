.PHONY: integration-tests

build:
	docker build -t flask-app .

integration-tests:
	docker run --rm flask-app bash -c "python -m unittest discover -s test/integration/"

run-app:
	docker run --rm -p 5000:5000 flask-app bash -c "python -m src.app"

flake8:
	# The GitHub editor is 127 chars wide
	flake8 . --extend-ignore=F405 --max-line-length=127 --exclude venv

pydocstyle:
	pydocstyle --convention=numpy --add-ignore=D100,D101,D102,D103,D104,D105,D106,D107 src tests

yamllint:
	yamllint .

pip-compile:
	docker run --rm -v ${PWD}:/foo -w="/foo" flask-app bash -c "pip-compile"
