# cloud_run_service/main.tf

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Read remote state from base_resources
data "terraform_remote_state" "base" {
  backend = "gcs" # or other backend your state is stored in
  config = {
    bucket = "remote-tf-state-share" #! Note: can not use variables here
    prefix = "base_resources"
  }
}

resource "google_cloud_run_service" "api_service" {
  name     = "fastapi-app"
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "10"
        "run.googleapis.com/client-name"   = "terraform"
      }
    }
    spec {
      service_account_name = data.terraform_remote_state.base.outputs.cloud_run_sa_email

      containers {
        image = "${data.terraform_remote_state.base.outputs.repository_url}/fastapi-app:latest"

        ports {
          container_port = 8080 # setting a custom port number to use
        }

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.api_service.name
  location = google_cloud_run_service.api_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "cloud_run_admin" {
  service  = google_cloud_run_service.api_service.name
  location = google_cloud_run_service.api_service.location
  role     = "roles/run.admin"
  member   = "serviceAccount:${data.terraform_remote_state.base.outputs.cloud_run_sa_email}"
}

# Outputs to be used by other Terraform configuration
# Output the URL where our service is running
output "cloud_run_service_url" {
  value       = google_cloud_run_service.api_service.status[0].url
  description = "URL of the deployed Cloud Run service"
}

# Output the registry URL for future image pushes
output "docker_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/docker-repo"
  description = "URL of the Docker registry"
}