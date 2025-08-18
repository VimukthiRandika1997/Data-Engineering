# Compute Engine
resource "google_compute_instance" "example" {
  name                      = "example-compute-instance"
  project                   = var.project_id
  zone                      = "${var.region}-a"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral external IP
    }
  }

}