#!/bin/bash

# exporting ENV variables defined in .env file
source ../shared/.env
GOOGLE_APPLICATION_CREDENTIALS="../shared/terraform-sa-key.json" #! weired dance to get around the path issue

# authenticate the service-account ( admin )
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS