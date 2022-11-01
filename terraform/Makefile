.PHONY: tflint tfsec infracost

DRUN = docker run --rm -v ${PWD}:/terraform

tflint:
	cd live

	# Install AWS plugin
	tflint --init

	# Parse files recursively and save output in a txt file
	find -type d -not -path '*.terraform/*' -exec tflint -f compact {} \;

tfsec:
	$(DRUN) aquasec/tfsec /terraform --minimum-severity HIGH

# call this command with: $make infracost INFRACOST_API_KEY=${INFRACOST_API_KEY}
infracost:
	# Run cost estimation for dev environment
	$(DRUN) -w / -e INFRACOST_API_KEY=${INFRACOST_API_KEY} \
	infracost/infracost:ci-latest breakdown --config-file terraform/live/infracost.yml --show-skipped
