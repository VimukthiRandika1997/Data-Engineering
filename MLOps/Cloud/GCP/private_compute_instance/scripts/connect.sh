#!/bin/bash

source ../.env

# As an user, you want to login into your gmail account using this
# gcloud auth login

gcloud compute ssh ${VM_NAME} --zone=${REGION}-a --tunnel-through-iap
# For finding issues when connecting
# gcloud compute ssh ${VM_NAME} --zone=${REGION}-a --tunnel-through-iap --troubleshoot