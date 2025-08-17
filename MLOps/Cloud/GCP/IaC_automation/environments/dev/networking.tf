# Firewall settings
resource "google_compute_firewall" "example_firewall" {
  name    = "example-firewall"
  project = var.gcp.project_id
  network = "default"

  # SSH access for GCE
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}