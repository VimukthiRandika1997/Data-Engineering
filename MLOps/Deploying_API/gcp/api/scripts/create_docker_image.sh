#!/bin/bash

# exporting ENV variables defined in .env file
source ../shared/.env

# Build the docker image
docker build -t ${REGISTRY_URL}/fastapi-app:latest ../


# Authenticate the service account: only for pushing the docker images to the registry
bash authenticate_admin_account.sh

# Authenticate Docker with our private registry
gcloud auth configure-docker ${TF_VAR_region}-docker.pkg.dev

# Push the image to our private repository
docker push ${REGISTRY_URL}/fastapi-app:latest