.PHONY: app-cicd infra-cicd

# Run full application code CICD locally with the exception of the push-to-registry job
app-cicd:
	# Run the full CICD pipeline without pushing to Docker Hub.
	act -W .github/workflows/app_code_cicd.yml --secret-file secrets.txt --artifact-server-path /tmp/artifacts

# Run full infrastructure code CICD locally
infra-cicd:
	act -W .github/workflows/infra_code_cicd.yml --secret-file secrets.txt
