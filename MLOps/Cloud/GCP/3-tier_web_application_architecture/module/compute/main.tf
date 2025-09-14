/*

This sets up a scalable, load-balanced web-server on GCP.

- Instance Template: defines how each web VM looks 
- MIG (Managed Instance Group): runs multiple identical VMs, spread across zones
- Health Check: checks `/health` endpoint on port 8080
- Backend service: groups MIG instances for load balancing
- URL Map -> HTTP Proxy -> Forwarding Rule: implements a Global HTTP Load Balancer (this exposes the app on port 80)
- Autoscaler: scales the MIG up/down based on CPU

This creates a highly available, auto-scaling web-server cluster, with a global HTTP load-balancer

*/

# Instance Template
# - defines the blueprint for VM instances
resource "google_compute_instance_template" "web_server_template" {
  name_prefix  = "web-server-template-"     # ensures unique template names each time
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-11" # Debian 11 as the OS
    auto_delete  = true                     # boot disk auto-deletes with the VM
    boot         = true
    disk_size_gb = 10                       # disk size
  }

  network_interface {
    subnetwork = var.subnet_name            # connects VM to a specific subnet
    access_config {
      # Ephemeral public IP
    }
  }

  # runs the startup script on boot
  metadata_startup_script = templatefile("${path.module}/../../scripts/startup-script.sh", {
    PROJECT_ID = var.project_id
    REGION     = var.region
    DB_NAME    = var.db_name
    DB_IP      = var.db_ip
  })

  tags = ["web-server", "ssh-access"]   # firewall rules can target these tags

  service_account {
    scopes = ["cloud-platform"]         # attaches a service account with full API access
  }

  lifecycle {
    create_before_destroy = true        # ensures a new template is created befor destroying the old one (zero downtime updates)
  }
}

# Managed Instance Group
# - creates a regional MIG (intances spread across zones in the region)
resource "google_compute_region_instance_group_manager" "web_server_group" {
  name   = "web-server-group"
  region = var.region

  base_instance_name = "web-server"
  target_size        = var.instance_count   # no.of instances

  version {
    instance_template = google_compute_instance_template.web_server_template.id
  }

  named_port {
    name = "http"   # declare port 8080 as HTTP service, this is used by load-balancer
    port = 8080
  }

  # uses a health-check to automatically recreate unhealthy VMs
  auto_healing_policies {
    health_check      = google_compute_health_check.web_server_health_check.id
    initial_delay_sec = 300                 # waits 5 minutes (300=60*5) after startup before evaluating health
  }
}

# Health Check
# - load-balancer pings `http://<vm>:8080/health` every 30 seconds
# - marks VMs unhealthy if they don't respond within 5 seconds
resource "google_compute_health_check" "web_server_health_check" {
  name = "web-server-health-check"

  timeout_sec        = 5
  check_interval_sec = 30

  http_health_check {
    port         = "8080"
    request_path = "/health"
  }
}

# Backend Service
# - defines a backend pool for the load balancer
# - uses HTTP protocol on named port `http` (8080)
# - requests timeout after 10s
resource "google_compute_backend_service" "web_server_backend" {
  name        = "web-server-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.web_server_health_check.id] # ensures only healthy VMs get traffic

  # binds the MIG as the backend
  backend {
    group           = google_compute_region_instance_group_manager.web_server_group.instance_group
    balancing_mode  = "UTILIZATION"     # load balances based on utilization
    capacity_scaler = 1.0               # increase the capacity to 100% (1.0)
  }

  depends_on = [
    google_compute_health_check.web_server_health_check,
    google_compute_region_instance_group_manager.web_server_group
  ]
}

# URL Map
# - routes all incoming requests to the backend service
resource "google_compute_url_map" "web_server_url_map" {
  name            = "web-server-url-map"
  default_service = google_compute_backend_service.web_server_backend.id
}

# HTTP Proxy
# - forwards requests to the URL map
resource "google_compute_target_http_proxy" "web_server_proxy" {
  name    = "web-server-proxy"
  url_map = google_compute_url_map.web_server_url_map.id
}

# Global Forwarding Rule (Load Balancer)
# - creates a global HTTP load-balancer frontend
# - listens on port 80, forwards traffic to the proxy -> URL map -> backend service -> MIG
resource "google_compute_global_forwarding_rule" "web_server_forwarding_rule" {
  name       = "web-server-forwarding-rule"
  target     = google_compute_target_http_proxy.web_server_proxy.id
  port_range = "80"
}

# Autoscaler
# - scales the MIG automatically
#   - between `var.instance_count` and 5 instances
#   - based on CPU utilization (70% target)
resource "google_compute_region_autoscaler" "web_server_autoscaler" {
  name   = "web-server-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_server_group.id

  autoscaling_policy {
    max_replicas    = 5         # maximum no.of instances
    min_replicas    = var.instance_count
    cooldown_period = 60        # prevents rapid scaling up/down

    cpu_utilization {
      target = 0.7
    }
  }
}