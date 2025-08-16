# Provider details
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "tf_state" {
  name          = var.terraform_tf_state_bucket
  location      = var.region # or your preferred region
  force_destroy = true       # allows bucket to be destroyed if not empty

  versioning {
    enabled = true # recommended for state file versioning and recovery
  }
}
