.PHONY: app-cicd

# Run full application code CICD locally with the exception of the push-to-registry job
app-cicd:
	# Run the full CICD pipeline without pushing to Docker Hub.
	# "--artifact-server-path" has to be specified as the workflow
	# is using "actions/upload-artifact" and "actions/download-artifact"
	# cf issue: https://github.com/nektos/act/issues/329#issuecomment-1187246629
	act -W .github/workflows/app_code_cicd.yml --secret-file secrets.txt --artifact-server-path /tmp/artifacts
