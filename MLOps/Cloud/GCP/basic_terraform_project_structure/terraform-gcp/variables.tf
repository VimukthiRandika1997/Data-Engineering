variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
  validation {
    condition     = length(var.project_id) > 6
    error_message = "Project ID must be more than 6 characters."
  }
}

variable "region" {
  type        = string
  description = "GCP region for resources"
  default     = "us-central1"
  validation {
    condition = contains([
      "us-central1", "us-east1", "us-west1", "us-west2",
      "europe-west1", "europe-west2", "asia-east1"
    ], var.region)
    error_message = "Region must be a valid GCP region."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "main-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "main-subnet"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range for the subnet"
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}