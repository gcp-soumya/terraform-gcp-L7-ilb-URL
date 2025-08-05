output "network_self_link" {
  description = "Self link of the VPC network created by the module."
  value       = google_compute_network.ilb_network.self_link
}

output "proxy_subnet_self_link" {
  description = "Self link of the proxy-only subnetwork."
  value       = google_compute_subnetwork.proxy_subnet.self_link
}

output "backend_subnet_self_link" {
  description = "Self link of the backend subnetwork."
  value       = google_compute_subnetwork.ilb_subnet.self_link
}

output "forwarding_rule_self_link" {
  description = "Self link of the L7 Internal Load Balancer forwarding rule."
  value       = google_compute_forwarding_rule.google_compute_forwarding_rule.self_link
}

output "forwarding_rule_ip_address" {
  description = "Internal IP address of the L7 Internal Load Balancer forwarding rule. This is the IP to which clients will send traffic."
  value       = google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address
}

output "backend_service_self_link" {
  description = "Self link of the backend service."
  value       = google_compute_region_backend_service.default.self_link
}

output "mig_instance_group_self_link" {
  description = "Self link of the Managed Instance Group's instance group."
  value       = google_compute_region_instance_group_manager.mig.instance_group
}

output "test_instance_name" {
  description = "Name of the created test instance (if enabled)."
  value       = var.create_test_instance ? google_compute_instance.vm_test[0].name : null
}

output "test_instance_private_ip" {
  description = "Private IP address of the created test instance (if enabled). Use this to test connectivity to the ILB."
  value       = var.create_test_instance ? google_compute_instance.vm_test[0].network_interface[0].network_ip : null
}
