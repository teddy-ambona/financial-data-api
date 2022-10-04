.PHONY: tfsec infracost

DRUN = docker run --rm -v ${PWD}:/terraform

tfsec:
	$(DRUN) aquasec/tfsec /terraform --minimum-severity HIGH

# call this command with: $make infracost INFRACOST_API_KEY=${INFRACOST_API_KEY}
infracost:
	# Run cost estimation for dev environment
	$(DRUN) -e INFRACOST_API_KEY=${INFRACOST_API_KEY} \
	infracost/infracost:ci-latest breakdown --path /terraform/live/global --show-skipped

	# Run cost estimation for resources in global region
	$(DRUN) -e INFRACOST_API_KEY=${INFRACOST_API_KEY} \
	infracost/infracost:ci-latest breakdown --path /terraform/live/dev --show-skipped

	# Run cost estimation for prod environment
	$(DRUN) -e INFRACOST_API_KEY=${INFRACOST_API_KEY} \
	infracost/infracost:ci-latest breakdown --path /terraform/live/prod --show-skipped
