output "db_ip" {
  description = "IP address of the database"
  value       = google_sql_database_instance.main.private_ip_address
}

output "db_name" {
  description = "Name of the database"
  value       = google_sql_database.database.name
}