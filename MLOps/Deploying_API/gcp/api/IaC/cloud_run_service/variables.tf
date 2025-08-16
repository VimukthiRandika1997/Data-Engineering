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

variable "terraform_sa_email" {
  type        = string
  description = "admin account to create resources"
}


# For Cloud Run
variable "environment" {
  type        = string
  description = "Environment, either prod or dev"
}