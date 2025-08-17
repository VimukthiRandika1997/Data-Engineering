#!/bin/bash

pushd ../
    # Create env variables
    cp .env.sample .env

    #! Uncomment to recreate them again!
    # Create project files
    # mkdir -p environments/dev
    # pushd environments/dev
    #     # for base files
    #     touch backends.tf main.tf providers.tf variables.tf versions.tf outputs.tf
    #     # resource specific files
    #     touch storage.tf networking.tf
    # popd

    # Add the workflow file
    mkdir -p .github/workflows
    cp terraform.yaml .github/workflows
popd