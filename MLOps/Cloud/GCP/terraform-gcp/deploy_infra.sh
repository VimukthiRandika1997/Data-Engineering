#!/bin/bash

# Export ENV variables
pushd ../
  if [ -f .env ]; then
    set -a
    . .env
    set +a
  else
    echo ".env file not found!"
    exit 1
  fi
popd


# Check if an argument is passed
if [ $# -eq 0 ]; then
  echo "Usage: $0 {create|destroy}"
  exit 1
fi

# Helper functions
function create_resources {
   # Initialize terraform: downloads provider plugins and initialize the working directory
    terraform init

    # Format & validate
    terraform fmt -recursive
    terraform validate

    # Plan: creates an execution plan and saves it to a file
    terraform plan -out=tfplan

    # Apply changes: executes the plan
    terraform apply tfplan

    # Verify deployment
    terraform output 
}


# Perform action based on argument
case $1 in
  create)
    create_resources
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