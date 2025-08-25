output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnets" {
  value = {
    public  = google_compute_subnetwork.public.ip_cidr_range
    private = google_compute_subnetwork.private.ip_cidr_range
  }
}

output "vm_self_link" {
  value = google_compute_instance.vm.self_link
}

output "vm_internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip
}
