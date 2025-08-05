
output "ilb_ip_address" {
  description = "The internal IP address of the L7 Internal Load Balancer."
  value       = module.l7_internal_lb.forwarding_rule_ip_address
}

output "test_vm_ip" {
  description = "The private IP address of the test VM (if created)."
  value       = module.l7_internal_lb.test_instance_private_ip
}