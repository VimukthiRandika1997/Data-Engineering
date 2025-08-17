output "vpc_name" {
  value       = google_compute_network.main_vpc.name
  description = "Name of the created VPC"
}

output "vpc_id" {
  value       = google_compute_network.main_vpc.id
  description = "ID of the created VPC"
}

output "vpc_self_link" {
  value       = google_compute_network.main_vpc.self_link
  description = "Self-link of the VPC (useful for other resources)"
}

output "subnet_name" {
  value       = google_compute_subnetwork.main_subnet.name
  description = "Name of the created subnet"
}

output "subnet_cidr" {
  value       = google_compute_subnetwork.main_subnet.ip_cidr_range
  description = "CIDR range of the subnet"
}

output "subnet_gateway_address" {
  value       = google_compute_subnetwork.main_subnet.gateway_address
  description = "Gateway IP address of the subnet"
}

output "terraform_state_bucket" {
  value       = google_storage_bucket.terraform_state.name
  description = "Name of the Terraform state storage bucket"
}

output "app_storage_bucket" {
  value       = google_storage_bucket.app_storage.name
  description = "Name of the application storage bucket"
}

output "cloud_router_name" {
  value       = google_compute_router.main_router.name
  description = "Name of the Cloud Router"
}

# Network details for use in subsequent parts
output "network_details" {
  value = {
    vpc_name    = google_compute_network.main_vpc.name
    subnet_name = google_compute_subnetwork.main_subnet.name
    region      = var.region
    project_id  = var.project_id
  }
  description = "Network configuration details for other Terraform configurations"
}