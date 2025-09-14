output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "private_ip_range_name" {
  description = "Name of the private IP range"
  value       = google_compute_global_address.private_ip_range.name
}