########################
# Enable required APIs #
########################
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "oslogin.googleapis.com"
  ])
  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

#################
# Network layer #
#################
resource "google_compute_network" "vpc" {
  name                            = var.network_name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "GLOBAL"
}

resource "google_compute_subnetwork" "public" {
  name                     = var.public_subnet_name
  ip_cidr_range            = var.subnet_public_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  purpose                  = "PRIVATE"
}

resource "google_compute_subnetwork" "private" {
  name                     = var.private_subnet_name
  ip_cidr_range            = var.subnet_private_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  purpose                  = "PRIVATE"
}

#########################
# Cloud Router &  NAT   #
#########################
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

##############################
# Firewall – least privilege #
##############################

# Allow internal east-west traffic (only within this VPC)
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["10.10.0.0/16"] # tighten to exact subnets if preferred

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH only via IAP to instances using this service account
# IAP TCP forwarding egress range: 35.235.240.0/20
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]

  target_service_accounts = [google_service_account.vm_sa.email]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

##########################
# VM service account/IAM #
##########################
resource "google_service_account" "vm_sa" {
  account_id   = "vm-runtime-sa"
  display_name = "VM runtime service account"
}

# Minimal, principle-of-least-privilege roles for telemetry
resource "google_project_iam_member" "sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_project_iam_member" "sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

# Custom IAM Role (Least privilege)
###########################

resource "google_project_iam_custom_role" "iap_oslogin_viewer" {
  role_id     = "iapOsLoginViewer"
  title       = "IAP OS Login Viewer"
  description = "Minimal permissions required for IAP + OS Login SSH"
  project     = var.project_id

  permissions = [
    "compute.instances.get",
    "compute.instances.list",
  ]
}


########################
# Compute Engine VM    #
########################
data "google_compute_image" "base" {
  family  = var.instance_image_family
  project = var.instance_image_project
}

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  zone         = "${var.region}-a"
  machine_type = var.instance_machine_type
  labels       = var.labels

  # No external IP: omit access_config
  network_interface {
    subnetwork = google_compute_subnetwork.private.name
    # No access_config block => private only
  }

  # OS Login and hardening
  metadata = {
    enable-oslogin            = "TRUE"
    block-project-ssh-keys    = "TRUE"
    serial-port-enable        = "FALSE"
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.base.self_link
      size  = 20
      type  = "pd-balanced"
    }
    auto_delete = true
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_vm
  }

  # Optional startup script placeholder (kept minimal)
  metadata_startup_script = <<-EOT
    #!/usr/bin/env bash
    set -euo pipefail
    apt-get update -y
    apt-get install -y htop
  EOT

  depends_on = [
    google_project_service.services,
    google_compute_router_nat.nat
  ]
}
