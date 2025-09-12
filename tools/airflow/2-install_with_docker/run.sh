#!/bin/bash

### - Step 1: Download the official docker-compose file - ###
# - download the official docker-compose.yaml for Airflow 3.0
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml'


### - Step 2: Create required directories - ###
# - airflow needs several directories for storing DAGs, logs and plugins
# - `AIRFLOW_UID` ENV defines files created by airflow have correct permissions
mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=$(id -u)" > .env


### - Step 3: Initialize the database - ###
# - this will create the necessary database tables and an admin user with some credentials:
#   - username: `airflow`
#   - password: `airflow`
docker compose up airflow-init


### - Step 4: Launch Airflow - ###
# - start all airflow services
#   - airflow-webserver: The web interface (accessible at http://localhost:8080)
#   - airflow-scheduler: Schedules and triggers tasks
#   - airflow-worker: Executes tasks (in CeleryExecutor mode)
#   - airflow-triggerer: Handles deferred tasks (new in Airflow 2.2+)
#   - postgres: Database backend
#   - redis: Message broker for Celery
docker compose up -d

### - Step 5: Access the web interface - ###
# - visit http://localhost:8080 and login with the credentials given during initialization
# - AIRFLOW__CORE__LOAD_EXAMPLES: 'false' if the samples DAGs are needed  to be removed
