terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
  }
}

# Specify GCP Project settings
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a Compute Engine Instance
resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250805" # use this to get the list: gcloud compute images list --filter ubuntu-os
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

# Create a Cloud Storage Bucket
resource "google_storage_bucket" "demo-bucket" {
  name          = var.cloud_bucket_name
  location      = var.cloud_bucket_location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}


# Reference the default VPC network
data "google_compute_network" "default" {
  name = "default"
}

# Allocate a private IP range for VPC peering with Cloud SQL
# resource "google_compute_global_address" "private_ip_range" {
#   name          = "private-ip-range"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 24
#   network       = data.google_compute_network.default.id
# }

# Create VPC peering connection between default network and Google services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["default-ip-range"]

  lifecycle {
    prevent_destroy = true # we don't need to delete default VPC Network
  }
}


# Create Cloud SQL instance using private IP on the default network
resource "google_sql_database_instance" "postgres_instance" {
  name             = var.postgres_db_instance_name
  database_version = "POSTGRES_15" # Change as needed
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro" # machine type, change as needed

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.default.id
    }

    # Optional backup configuration
    backup_configuration {
      enabled = true
    }
  }
   deletion_protection = false
}

# Create a PostgreSQL database inside the instance
resource "google_sql_database" "postgres_db" {
  name     = var.postgres_db_name
  instance = google_sql_database_instance.postgres_instance.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
}

# Create a user for the database
resource "google_sql_user" "postgres_user" {
  name     = var.postgres_db_username
  instance = google_sql_database_instance.postgres_instance.name
  password = var.postgres_db_password  # store password in a variable or secret manager
}
