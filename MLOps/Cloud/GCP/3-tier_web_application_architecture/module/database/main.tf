/*
This sets up a Cloud SQL for MySQL instance in GCP

- Cloud SQL MySQL instance (private IP only, no public access)
- Automate backups ( daily, 7 days retention)
- A specific database inside the instance
- A user with a provided password (generates a random password but doesn't use it yet)

*/

# Random password for root user
# - currently not in used
resource "random_password" "root_password" {
  length  = 16
  special = true
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name                = "terraform-db-instance"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false           # allows to delete the instance, set to true in production

  depends_on = [var.private_ip_range]   # ensures the private IP range peering exists before provisioning

  settings {
    tier = "db-f1-micro"                # machine type to be used: for dev/test

    backup_configuration {              # daily backups enabled
      enabled                        = true 
      start_time                     = "02:00"  # backup window starts at 2 AM
      point_in_time_recovery_enabled = false
      backup_retention_settings {
        retained_backups = 7                    # keeps only 7 backups
      }
    }

    ip_configuration {                  # disable public IP -> database is not exposed to the Internet
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/${var.network_name}"    # attaches to the VPC private IP -> so only workloads in the VPC can connect (VM instance, GKE)
    }

    database_flags {                    # disable slow query logs: can be enabled if needed for performance tuning
      name  = "slow_query_log"
      value = "off"
    }
  }
}

# Database
#   - creates a database inside the SQL instance
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

# Database User
#   - creates a user in the database instance
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password
}