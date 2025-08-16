#!/bin/bash

# Authentication: using a service account (in this case this is not need as url is publicly accessible)

# Get the Cloud Run service URL from remote state output
SERVICE_URL=$(terraform output -raw cloud_run_service_url)

echo "Testing service at $SERVICE_URL"

# Test endpoints
curl "$SERVICE_URL/"
curl "$SERVICE_URL/health"
curl "$SERVICE_URL/items/123?q=test"
