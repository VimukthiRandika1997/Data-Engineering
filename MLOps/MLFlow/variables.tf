# Settings for Project
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zone" {
  type        = string
  description = "GCP zone"
}


# Settings for VM
variable "machine_type" {
  type        = string
  description = "GCP Compute Engine type"
}

variable "machine_name" {
  type        = string
  description = "GCP Compute instance's name"
}


# Settings for Cloud Storage
variable "cloud_bucket_name" {
  type        = string
  description = "GCP Cloud Storage name"
}

variable "cloud_bucket_location" {
  type        = string
  description = "GCP Cloud Storage location"
}


# Settings for PostgreSQL DB instance
variable "postgres_db_instance_name" {
  type        = string
  description = "GCP Cloud postgres db instance name"
}

variable "postgres_db_name" {
  type        = string
  description = "GCP Cloud postgres db name"
}

variable "postgres_db_username" {
  type        = string
  description = "GCP Cloud postgres db username"
}

variable "postgres_db_password" {
  type        = string
  description = "GCP Cloud postgres db user password"
}