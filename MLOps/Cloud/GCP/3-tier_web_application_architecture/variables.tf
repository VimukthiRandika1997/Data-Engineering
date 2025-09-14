variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "terraform-vpc"
}

variable "instance_count" {
  description = "Number of compute instances"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "webapp_db"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "webapp_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}