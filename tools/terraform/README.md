# Creating Cloud Resources using Terraform

## GCP
01. Make a main.tf file to specify the resources

```tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "<gcp_project_id>"
  region  = "us-central1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "terraform-demo-1997-terra-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}
```

2. Setup the service account keys in `run.sh` and run the script

```bash
bash run.sh
```