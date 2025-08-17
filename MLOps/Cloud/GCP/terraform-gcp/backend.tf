# Local backend for initial setup
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# After creating the storage bucket, uncomment below and migrate:
# terraform {
#   backend "gcs" {
#     bucket = "your-project-id-dev-terraform-state"
#     prefix = "foundation/state"
#   }
# }