#!/bin/bash

# Check if an argument is passed
if [ $# -eq 0 ]; then
  echo "Usage: $0 {create|destroy}"
  exit 1
fi

# Initialize Terraform
terraform init
terraform fmt -recursive
terraform validate

# Perform action based on argument
case $1 in
  create)
    terraform apply -auto-approve
    ;;
  destroy)
    terraform destroy -auto-approve
    ;;
  *)
    echo "Invalid argument: $1"
    echo "Usage: $0 {create|destroy}"
    exit 1
    ;;
esac

