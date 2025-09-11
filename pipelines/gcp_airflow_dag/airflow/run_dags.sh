#!/bin/bash

# Need to create these directories manually, otherwise
# airflow container can not find or store DAGs, logs or plugins
rm -r ./logs || true
mkdir ./logs ./plugins || true
echo -e "AIRFLOW_UID=$(id -u)" > .env


# Build the docker image
# docker build . --tag extending_airflow:latest

# Run the airflow through Docker-compose
docker-compose up airflow-init
docker-compose up -d