variable "project_id" {
  description = "The GCP project where the bucket will be created"
  type        = string
}

variable "region" {
  description = "Region for the bucket"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  type      = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  type        = string
}

variable "terraform_sa_email" {
  description = "Email of the Terraform service account"
  type        = string
}
