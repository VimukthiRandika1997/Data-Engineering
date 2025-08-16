#!/bin/bash

source ../shared/.env
gcloud iam service-accounts delete terraform@${TF_VAR_project_id}.iam.gserviceaccount.com
rm terraform-sa-key.json || true