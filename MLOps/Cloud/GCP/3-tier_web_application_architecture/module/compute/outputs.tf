output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.web_server_forwarding_rule.ip_address
}

output "instance_ips" {
  description = "IP addresses of compute instances"
  value       = google_compute_region_instance_group_manager.web_server_group.instance_group
}