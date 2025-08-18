#!/bin/bash

# Exporting ENV variables
source ../.env

gcloud config set project $project_id

# Create service account for Terraform
gcloud iam service-accounts create terraform-automation \
    --description="Service account for Terraform infrastructure automation" \
    --display-name="Terraform Automation SA"

# Grant owner role (development only)
gcloud projects add-iam-policy-binding $project_id \
    --member="serviceAccount:terraform-automation@${project_id}.iam.gserviceaccount.com" \
    --role="roles/owner"

# Generate service account key
gcloud iam service-accounts keys create terraform-sa-key.json \
    --iam-account terraform-automation@${project_id}.iam.gserviceaccount.com