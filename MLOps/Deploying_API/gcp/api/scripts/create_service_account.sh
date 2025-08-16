#!/bin/bash

#** gcloud CLI should be installed and authenticated before running this

### - 0. Exporting ENV variables defined in .env file - ###
source ../shared/.env


### - 1. Create a service account - ###
gcloud iam service-accounts create terraform \
  --display-name "Terraform service account"


### - 2. Assign required roles to the service account - ###

# - Allows managing IAM policies (needed if Terraform modifies IAM bindings)
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

# - Allow viewer access to list project's resources ( at least viewer access)
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageViewer"

# - Full Cloud Run admin permissions for deploying and managing Cloud Run services
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# - Allows Terraform to impersonate service accounts (e.g., the Cloud Run service account)
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# - Allow to create artifcat registeries
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

# - Read access to Artifact Registry to pull container images
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"

# - Allow to create Cloud Storage Buckets
gcloud projects add-iam-policy-binding rosy-flames-467808-t2 \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# - Allows to create service accounts
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

# - Allows to write logs to Cloud Logging
gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
  --member="serviceAccount:terraform@${TF_VAR_project_id}.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"


### - 3. Generate and Use Service Account Key - ###
gcloud iam service-accounts keys create ../shared/terraform-sa-key.json \
  --iam-account=terraform@${TF_VAR_project_id}.iam.gserviceaccount.com

# Optional: exporting for later usage
export GOOGLE_APPLICATION_CREDENTIALS="../shared/terraform-sa-key.json" 