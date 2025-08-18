provider "google" {
  project = var.project_id
  region  = var.region
}

# GCS bucket for Terraform remote state (remote backend)
resource "google_storage_bucket" "terraform_state" {
  name                        = var.bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  # Uniform bucket-level access for better security
  uniform_bucket_level_access = true

  # Force destroy for development (disable in production)
  force_destroy = var.environment == "dev" ? true : false

  # Enable versioning for state file safety
  versioning {
    enabled = true
  }

  # Lifecycle management to control costs
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }

  # Labels for resource management
  labels = {
    environment = var.environment
    purpose     = "terraform-state"
    managed-by  = "terraform"
  }
}

# Grant access to Terraform service account
resource "google_storage_bucket_iam_member" "terraform_sa" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.terraform_sa_email}"
}
