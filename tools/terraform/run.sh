#!/bin/bash

### - Set the GCP credential keys - ###
export GOOGLE_APPLICATION_CREDENTIALS="/media/vimukthi/Vimax4/Repos/Keys/learner-gcp-key.json"
# Refresh token/session, and verify authentication
gcloud auth application-default login

### - Create the resources - ###
# 01. initializing
terraform init
# 02. create a plan
terraform plan
# 03. create resources
terraform apply
# 04. destroy resources
# terraform destroy