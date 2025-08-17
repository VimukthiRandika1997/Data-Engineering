provider "google" {
  region      = var.gcp.region
  project     = var.gcp.project_id
  credentials = var.GCP_CREDENTIALS
}