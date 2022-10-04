.PHONY: tfsec infracost

DRUN = docker run --rm -v ${PWD}:/terraform

tfsec:
	$(DRUN) aquasec/tfsec /terraform --minimum-severity HIGH

# call this command with: $make infracost INFRACOST_API_KEY=${INFRACOST_API_KEY}
infracost:
	# Run cost estimation for dev environment
	$(DRUN) -w / -e INFRACOST_API_KEY=${INFRACOST_API_KEY} \
	infracost/infracost:ci-latest breakdown --config-file terraform/infracost.yml --show-skipped
