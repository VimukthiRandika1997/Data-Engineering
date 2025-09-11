import logging
import os
from datetime import datetime

import pyarrow.csv as pv
import pyarrow.parquet as pq
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyDatasetOperator, BigQueryInsertJobOperator
from google.cloud import storage

from airflow import DAG


# -------------------
# ENV Variables
# -------------------
PROJECT_ID = os.environ.get('GCP_PROJECT_ID')
BUCKET = os.environ.get('GCP_GCS_BUCKET')
DATASET_NAME = os.environ.get("GCP_DATASET_NAME", 'my_taxi_dataset')
TABLE_NAME = os.environ.get("GCP_TABLE_NAME", 'taxi_table')
# path (URL) to download the dataset
URL_PREFIX = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
AIRFLOW_HOME = '/opt/airflow' # Airflow working directory inside the docker container


# -------------------
# Filepath templates
# -------------------
# - uses Airflow Jinia templates ({{ execution_date.strftime(...) }}) to dynamically build fiilename for each month when the DAG runs
# - example: 
#   - execution_time: the logical date the DAG run represents
#   - run date: the actual clock tiem when Airflow runs the DAG
#   - for January 2021 url becomes => https://github.com/.../yellow_tripdata_2021-01.csv.gz
YELLOW_TAXI_URL_TEMPLATE = URL_PREFIX + \
    '/yellow_tripdata_{{ execution_date.strftime(\'%Y-%m\') }}.csv.gz'
YELLOW_TAXI_CSV_FILE_TEMPLATE = AIRFLOW_HOME + \
    '/yellow_tripdata_{{ execution_date.strftime(\'%Y-%m\') }}.csv'

FILENAME = '/yellow_tripdata_{{ execution_date.strftime(\'%Y-%m\') }}.parquet'
YELLOW_TAXI_PARQUET_FILE_TEMPLATE = AIRFLOW_HOME + FILENAME
YELLOW_TAXI_GCP_PATH_TEMPLATE = 'raw/yellow_tripdata/{{ execution_date.strftime(\'%Y\') }}'


# -------------------
# Helper function
# -------------------
def format_to_parquet(src_file, destination_file):
    """Convert to parquet file"""

    if not (src_file.endswith('.csv') or src_file.endswith('.csv.gz')):
        logging.error('Can only accept source files in CSV format')
        return

    table = pv.read_csv(src_file)            # reads the CSV into an Arrow table
    pq.write_table(table, destination_file)                    # writes it as Parquet for efficient storage and querying


def upload_to_gcs(bucket, object_name, local_file):
    """Upload the file from local Airflow containe to GCS bucket"""

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)
    print(
        f'File {local_file} uploaded to {bucket}.'
    )


# -------------------
# DAG Definition
# -------------------
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2021, 1, 1),     # DAG starts from 2021 JAN
    'depends_on_past': False,               # No dependency on past runs
    'retries': 1,                           # Retries failed tasks once
}

# Note: 
# - backfill in Airflow:
#   - running all missed historical DAG runs from start_date to now, based on schedule_interval, controlled by catchup=True/False
with DAG(
    dag_id='data_ingestion_gcs_dag_v5.0',
    start_date=datetime(2021, 1, 1),
    schedule_interval='0 6 2 * *',          # DAG runs every 2nd day of month at 6 AM
    default_args=default_args,
    catchup=True,                           # When DAG is started, it will backfill all past months since start_date: useful when we need to historical data
    max_active_runs=3,                      # At most 3 DAG runs in parallel
    tags=['dtc-de'],
) as dag:

    # Task 1: Download CSV
    download_dataset_task = BashOperator(
        task_id='download_dataset_task',
        # bash_command=f'curl -sSLf {YELLOW_TAXI_URL_TEMPLATE} > {YELLOW_TAXI_CSV_FILE_TEMPLATE}'
        bash_command=f'curl -sSLf {YELLOW_TAXI_URL_TEMPLATE} | gunzip -c > {YELLOW_TAXI_CSV_FILE_TEMPLATE}'
    )

    # Task 2: Convert CSV → Parquet
    format_to_parquet_task = PythonOperator(
        task_id='format_to_parquet_task',
        python_callable=format_to_parquet,
        op_kwargs={
            'src_file': YELLOW_TAXI_CSV_FILE_TEMPLATE,
            'destination_file': YELLOW_TAXI_PARQUET_FILE_TEMPLATE
        },
    )

    # Task 3: Upload Parquet to GCS
    upload_local_to_gcs_task = PythonOperator(
        task_id='upload_local_to_gcs_task',
        python_callable=upload_to_gcs,
        op_kwargs={
            'bucket': BUCKET,
            'object_name': YELLOW_TAXI_GCP_PATH_TEMPLATE + FILENAME,
            'local_file': YELLOW_TAXI_PARQUET_FILE_TEMPLATE,
        },
    )

    # Task 4: Create BigQuery dataset (if not exists)
    create_dataset = BigQueryCreateEmptyDatasetOperator(
        task_id="create_bq_dataset_task",
        dataset_id=DATASET_NAME,
        project_id=PROJECT_ID,
        location="US",
    )

    # Task 5: Create BigQuery external table from GCS file
    create_bq_table = BigQueryInsertJobOperator(
        task_id="load_bq_partitioned_table_task",
        configuration={
            "load": {
                "destinationTable": {
                    "projectId": PROJECT_ID,
                    "datasetId": DATASET_NAME,
                    "tableId": TABLE_NAME,
                },
                "sourceUris": [
                    f"gs://{BUCKET}/" + YELLOW_TAXI_GCP_PATH_TEMPLATE + "/*.parquet"
                ],
                "sourceFormat": "PARQUET",
                "writeDisposition": "WRITE_APPEND",
                "schema": {
                    "fields": [
                        {"name": "VendorID", "type": "INTEGER"},
                        {"name": "tpep_pickup_datetime", "type": "TIMESTAMP"},
                        {"name": "tpep_dropoff_datetime", "type": "TIMESTAMP"},
                        {"name": "passenger_count", "type": "INTEGER"},
                        {"name": "trip_distance", "type": "FLOAT"},
                        {"name": "RatecodeID", "type": "INTEGER"},
                        {"name": "store_and_fwd_flag", "type": "STRING"},
                        {"name": "PULocationID", "type": "INTEGER"},
                        {"name": "DOLocationID", "type": "INTEGER"},
                        {"name": "payment_type", "type": "INTEGER"},
                        {"name": "fare_amount", "type": "FLOAT"},
                        {"name": "extra", "type": "FLOAT"},
                        {"name": "mta_tax", "type": "FLOAT"},
                        {"name": "tip_amount", "type": "FLOAT"},
                        {"name": "tolls_amount", "type": "FLOAT"},
                        {"name": "improvement_surcharge", "type": "FLOAT"},
                        {"name": "total_amount", "type": "FLOAT"},
                        {"name": "congestion_surcharge", "type": "FLOAT"},
                    ]
                },
                "timePartitioning": {
                    "type": "MONTH",
                    "field": "tpep_pickup_datetime"  # partition by pickup date
                },
                "clustering": {
                    "fields": ["PULocationID", "DOLocationID"]
                }
            }
        },
    )

    # Task Orchestration: defines how DAG flows
    download_dataset_task >> format_to_parquet_task >> upload_local_to_gcs_task >> create_dataset