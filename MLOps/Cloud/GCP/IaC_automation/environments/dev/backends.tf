# Local backend for initial setup
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# After creating the storage bucket, uncomment below and migrate:
# terraform {
#   backend "gcs" {
#     bucket = "<your-project-id>-dev-terraform-state" # Add your GCP project_id
#     prefix = "terraform/state/dev"
#   }

#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = ">= 4.60"
#     }
#   }
# }