terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Network Module
module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
}

# Database Module
module "database" {
  source = "./modules/database"

  project_id       = var.project_id
  region           = var.region
  network_name     = module.network.vpc_network_name
  private_ip_range = module.network.private_ip_range_name
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = var.db_password
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_id     = var.project_id
  region         = var.region
  zone           = var.zone
  network_name   = module.network.vpc_network_name
  subnet_name    = module.network.subnet_name
  instance_count = var.instance_count
  machine_type   = var.machine_type
  db_ip          = module.database.db_ip
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
}