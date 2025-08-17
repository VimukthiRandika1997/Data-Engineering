#!/bin/bash

# Exporting ENV variables
source .env

gcloud config set project $TF_VAR_project_id

# Create service account for Terraform
gcloud iam service-accounts create terraform-automation \
    --description="Service account for Terraform infrastructure automation" \
    --display-name="Terraform Automation SA"

# Grant owner role (development only)
gcloud projects add-iam-policy-binding $TF_VAR_project_id \
    --member="serviceAccount:terraform-automation@${TF_VAR_project_id}.iam.gserviceaccount.com" \
    --role="roles/owner"

# Generate service account key
gcloud iam service-accounts keys create terraform-sa-key.json \
    --iam-account terraform-automation@${TF_VAR_project_id}.iam.gserviceaccount.com

# Authenticate the service-account
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS