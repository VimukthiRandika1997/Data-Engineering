output "terraform_state_bucket" {
  value       = google_storage_bucket.terraform_state.name
  description = "Name of the Terraform state storage bucket"
}