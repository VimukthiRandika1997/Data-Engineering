# Upload files to cloud storage
# - files will be uploaded via terraform to GCS bucket -> so those can be used by Dataflow job
resource "google_storage_bucket_object" "js_file" {
  name   = "${var.gcs_folder_location}/${var.js_file_source}" # GCS filepath
  source = var.js_file_source                                 # Local filepath
  bucket = var.gcs_bucket_name
}

resource "google_storage_bucket_object" "sample_data" {
  name   = "${var.gcs_folder_location}/${var.sample_data_source}"
  source = var.sample_data_source
  bucket = var.gcs_bucket_name
}

resource "google_storage_bucket_object" "bq_schema" {
  name   = "${var.gcs_folder_location}/${var.bq_schema_source}"
  source = var.bq_schema_source
  bucket = var.gcs_bucket_name
}


locals {
  bq_table_name = "${var.project_id}:${var.bq_dataset_name}.${var.bq_table_name}"
}


# Create dataflow job
# - For getting template's parameters: https://cloud.google.com/dataflow/docs/guides/templates/provided/cloud-storage-to-bigquery#run-the-template
resource "google_dataflow_job" "gcs_to_bq" {
  name              = var.google_dataflow_job
  template_gcs_path = var.dataflow_template_source
  temp_gcs_location = "gs://${var.gcs_bucket_name}/temp"
  region            = var.region

  parameters = {
    javascriptTextTransformFunctionName = var.js_function_name
    JSONPath                            = "gs://${var.gcs_bucket_name}/${var.gcs_folder_location}/${var.bq_schema_source}"
    javascriptTextTransformGcsPath      = "gs://${var.gcs_bucket_name}/${var.gcs_folder_location}/${var.js_file_source}"
    inputFilePattern                    = "gs://${var.gcs_bucket_name}/${var.gcs_folder_location}/${var.sample_data_source}"
    outputTable                         = local.bq_table_name
    bigQueryLoadingTemporaryDirectory   = "gs://${var.gcs_bucket_name}/temp"
  }
}