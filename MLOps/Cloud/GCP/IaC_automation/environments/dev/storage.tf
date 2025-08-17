# Storage bucket for Terraform state (remote backend)
resource "google_storage_bucket" "terraform_state" {
  name     = "${var.gcp.project_id}-${var.environment}-terraform-state"
  project  = var.gcp.project_id
  location = var.gcp.region

  # Force destroy for development (disable in production)
  force_destroy = var.environment == "dev" ? true : false

  # Enable versioning for state file safety
  versioning {
    enabled = true
  }

  # Uniform bucket-level access for better security
  uniform_bucket_level_access = true

  # Lifecycle management to control costs
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age        = 7
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Labels for resource management
  labels = {
    environment = var.environment
    purpose     = "terraform-state"
    managed-by  = "terraform"
  }
}