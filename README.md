This repo is a template for dockerized flask applications(REST API). You will find the following implementation:

- Github Actions CICD
- Local Docker DB setup
- Docker image build pattern
- Flask blueprints
- Testing patterns
- Dependency injection

# Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- If running on windows: [Docker remote containers on WSL 2](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers)

# Quickstart

Run the following commands to build the Docker image and run the app:

```
make build
```

```
make run-app
```

Verify the API is running:

```
curl -I http://127.0.0.1:5000/_healthcheck
```
