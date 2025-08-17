# VPC Network
resource "google_compute_network" "main_vpc" {
  name                    = "${var.environment}-${var.vpc_name}"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460

  description = "Main VPC network for ${var.environment} environment"

  # Enable deletion protection in production
  delete_default_routes_on_create = false
}

# Subnet
resource "google_compute_subnetwork" "main_subnet" {
  name                     = "${var.environment}-${var.subnet_name}"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.main_vpc.name
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  description = "Primary subnet in ${var.region} for ${var.environment}"

  # Enable flow logs for security monitoring
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  # Secondary IP ranges for future use (GKE, etc.)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Cloud Router for Cloud NAT 
resource "google_compute_router" "main_router" {
  name    = "${var.environment}-cloud-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.main_vpc.id

  description = "Cloud Router for NAT gateway"
}