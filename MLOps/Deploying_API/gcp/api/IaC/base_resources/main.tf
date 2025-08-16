# base_resources/main.tf

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket = "remote-tf-state-share"
    prefix = "base_resources" # folder path in the bucket to organize state files
  }
}

# Enable required APIs
resource "google_project_service" "artifact_registry_api" {
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}
resource "google_project_service" "cloud_run_api" {
  service                    = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

# Artifact Registry repository
resource "google_artifact_registry_repository" "docker_images" {
  location      = var.region
  repository_id = "docker-images"
  description   = "Artifact Registry for our applications"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry_api]
}

# Service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  description  = "Service account for Cloud Run services"
}

# Grant Terraform user or service account permission to pull images from Artifact Registry
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

# Allow Terraform user or service account to act as Cloud Run service account
resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

# Outputs to be used by other Terraform configuration
output "cloud_run_sa_email" {
  value = google_service_account.cloud_run_sa.email
}

output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/docker-images"
}
