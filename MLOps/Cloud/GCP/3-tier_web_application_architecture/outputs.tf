output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = module.compute.load_balancer_ip
}

output "instance_ips" {
  description = "IP addresses of compute instances"
  value       = module.compute.instance_ips
}

output "database_ip" {
  description = "IP address of the database"
  value       = module.database.db_ip
  sensitive   = true
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.network.vpc_network_name
}