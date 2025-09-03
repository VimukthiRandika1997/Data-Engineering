variable "project_id" {
  type        = string
  description = "Google project ID"
}

variable "region" {
  type        = string
  description = "Google project region"
}

variable "gcs_bucket_name" {
  type        = string
  description = "Google Cloud Storage bucket name"
  default     = "dataflow-bucket-gcp-practice-project"
}

variable "gcs_folder_location" {
  type        = string
  description = "Google Cloud Storage folder location"
  default     = "via_terraform"
}

variable "js_file_source" {
  type        = string
  description = "Javascript file name"
  default     = "transform_function/transform.js"
}

variable "sample_data_source" {
  type        = string
  description = "Sample data file name"
  default     = "data/employee_data.csv"
}

variable "bq_schema_source" {
  type        = string
  description = "BigQuery schema file name"
  default     = "config/bq-schema.json"
}

variable "google_dataflow_job" {
  type        = string
  description = "Google Dataflow job name"
  default     = "gcs-to-bq-via-terraform"
}

variable "dataflow_template_source" {
  type        = string
  description = "Google Dataflow template source"
  default     = "gs://dataflow-templates/latest/GCS_Text_to_BigQuery"
}

variable "js_function_name" {
  type        = string
  description = "Javascript function name"
  default     = "transform"
}

variable "bq_dataset_name" {
  type        = string
  description = "BigQuery dataset name"
  default     = "dataflow_template_dataset"
}

variable "bq_table_name" {
  type        = string
  description = "BigQuery table name"
  default     = "dataflow_template_table"
}