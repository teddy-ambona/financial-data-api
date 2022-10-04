.PHONY: tfsec infracost

DRUN = docker run --rm -v ${PWD}:/foo

tfsec:
	$(DRUN) aquasec/tfsec /foo --minimum-severity HIGH

infracost:
	# use docker here
