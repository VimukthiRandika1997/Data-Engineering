<!-- markdownlint-disable no-inline-html -->
# Google Dataflow Job Deployment with Terraform: GCS to BigQuery

![Overview](/MLOps/Cloud/GCP/gcp_dataflow/gcs_to_bigquery/assets/gcs_to_bigquery_with_dataflow.png)

In this project, we're using Google Cloud Platform's Dataflow service. 

- A custom template is created to run a batch process
- It reads data from GCS bucket once a new file is placed within the bucket
- The result is stored to a BigQuery Table

# Tech Stack

- GCS (Google Cloud Storage)
- BigQuery (Google serverless data warehouse)
- Dataflow (Google serverless service for executing data processing pipelines)
- Terraform (Infrastructure as a code)

# Modular Architecture Diagram

```bash
        ┌─────────────────┐
        │   Terraform     │
        │ (IaC Deployment)│
        └───────┬─────────┘
                │
 ┌──────────────▼───────────────┐
 │      Google Cloud Storage     │
 │ (Raw Data Bucket - Input CSVs)│
 └──────────────┬───────────────┘
                │ (New file event)
                ▼
         ┌───────────────┐
         │   Dataflow     │
         │ (Batch Pipeline│
         │ Custom Template) 
         └───────────────┘
                │
                ▼
       ┌─────────────────┐
       │    BigQuery     │
       │ (Processed Data │
       │   Analytics)    │
       └─────────────────┘

```

# How to run

1. Create a GCS bucket in your GCP project
2. Create a BigQuery dataset and a table
    - Dataset name: `dataflow_template_dataset`
    - Table name: `dataflow_template_table`

3. Update the terrform variables by specifying your GCP project name and region: `terraform.tfvars`
4. Run the script to trigger the pipeline

```bash
bash trigger_pipeline.sh create  # for updating file
bash trigger_pipeline.sh destroy # for removing files from GCS bucket
```

5. Visit BigQuery section in GCP

![Result](/MLOps/Cloud/GCP/gcp_dataflow/gcs_to_bigquery/assets/GCP_Dataflow_intro.png)
