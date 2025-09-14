/*
This sets up a custom VPC
- A subnet with both primary and secondary ranges: useful for GKE
- A private IP range + peering connection for managed services: for Cloud SQL
- Firewall rules:
  - HTTP/HTTPS web traffic
  - SSH access
  - Load balancer health checks

This builds a secure VPC environment with Kubernets/GKE compatibility and
private access to Google managed services.
*/


# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false           # prevents creating default subnets
  routing_mode            = "REGIONAL"      # routing happens regionally instead of globally
}


# Subnet
# - defines a subnet inside the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = "10.0.1.0/24"             # primary CIDR range
  region        = var.region
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {                      # for GKE: for assigning pod IPs
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
}


# Private IP range for services
# - required for Private Service Access
# - reserves an internal IP range(/16) for VPC peering with Google managed services (Cloud SQL)
resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"         
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}


# VPC Peering for private services
# - creates a VPC peering connection between VPC and Google Service Networking API
# - This is required for accessing Google managed services (Cloud SQL, etc) using interal IPs
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}


# Firewall Rules
# - Allow HTTP
#   - allows inbound TCP traffic on ports 80(HTTP) and 8080
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-2"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]     # from anywhere
  target_tags   = ["web-server"]    # applies only to VMs tagged `web-server`
}


# - Allow HTTPS
#   - allows inbound HTTPS(port 443) from anywhere
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https-2"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]     # from anywhere
  target_tags   = ["web-server"]    # applies only to VMs tagged `web-server`
}


# - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-2"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"                # from anywhere
    ports    = ["22"]               # applies only to VMs tagged `ssh-access`
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
}


# - Allow Health Checks
#   - allows load-balancer health chech ranges to reach VMs on port 8080
#   - ensures that backend services behind load-balancers can be monitored properly
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web-server"]
}