# Local Apache Airflow Setup with GCP

![Setup](/pipelines/gcp_airflow_dag/assets/airflow_dag_with_gcp.png)

This project demonstrates how to:

- **Run Apache Airflow Locally**: Utilize Docker to set up Airflow in a local environment.
- **Authenticate with GCP**: Use the `gcloud` CLI to authenticate Airflow with GCP services, enabling interactions with resources like `BigQuery`, `Cloud Storage`.
- **Infrastructure Provisioning**: Use Terraform to create cloud resources. 

This approach can be an useful setup for **development/testing**, because we can iterate locally without spinning up a full cloud-managed workflow system like **Cloud Composer**.

# Overview

Diagram:

- Left: Local Airflow running in Docker.
- Right: GCP remote services.
- Converging node `Workflow Ready` indicates that Airflow and GCP are fully set up to execute DAGs.
- Arrow from Worker -> GCPAuth: Shows that Airflow tasks running locally can access remote GCP resources.
- Multiple GCP services: BigQuery, Cloud Storage, and Terraform provisioning are represented.

How it works:

1. **Airflow Setup**: Entry point for running Airflow locally.
2. **DockerPath**: Steps to start Airflow via Docker and ensure all services (webserver, scheduler, worker) are running.
3. **GCPPath**: Steps to authenticate and access remote GCP resources (BigQuery, Cloud Storage, Terraform provisioning).
4. **WorkflowReady**: Both paths converge here, meaning Airflow is ready to run DAGs that interact with GCP.

Now this is a fully functional local Airflow cluster (with Postgres backend, webserver, scheduler, triggerer) configured to connect securely to Google Cloud.

# How to run

## 1. Create Cloud Resources

1. Update the terrform variables by specifying your GCP project name and region: `terraform.tfvars`
2. Run the script to trigger the pipeline

    ```bash
    cd /Iac
    bash create_resources.sh create  # for creating resources
    bash create_resources.sh destroy # for removing resources
    ```

## 2. Trigger the DAG created using Airflow

- Add your GCP credential file `google_credentials.json` in a folder called `airflow/credentials`
- Run the below commands :

    ```bash
    # 1. create the docker containers
    bash run_dags.sh

    # 2. run the DAG 
    docker exec -it airflow_airflow-webserver_1 bash # this enters to airflow container
    airflow dags backfill -s 2021-04-01 -e 2021-08-01 data_ingestion_gcs_dag_v1.0 # manual backfill
    ```