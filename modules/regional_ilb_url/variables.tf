variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
  default = "prj-dd-p-net"
}

variable "region" {
  description = "The GCP region for the L7 Internal Load Balancer and associated resources."
  type        = string
  default     = "europe-west1"
}

variable "network_name" {
  description = "Name of the VPC network for the ILB."
  type        = string
  default     = "l7-ilb-network"
}

variable "proxy_subnet_name" {
  description = "Name of the proxy-only subnetwork for the ILB."
  type        = string
  default     = "l7-ilb-proxy-subnet"
}

variable "proxy_subnet_cidr" {
  description = "IP CIDR range for the proxy-only subnetwork."
  type        = string
  default     = "10.0.0.0/24"
}

variable "backend_subnet_name" {
  description = "Name of the backend subnetwork for instances."
  type        = string
  default     = "l7-ilb-subnet"
}

variable "backend_subnet_cidr" {
  description = "IP CIDR range for the backend subnetwork."
  type        = string
  default     = "10.0.1.0/24"
}

variable "forwarding_rule_name" {
  description = "Name of the forwarding rule for the ILB."
  type        = string
  default     = "l7-ilb-forwarding-rule"
}

variable "forwarding_rule_ip_protocol" {
  description = "IP protocol for the forwarding rule (e.g., TCP)."
  type        = string
  default     = "TCP"
}

variable "forwarding_rule_port_range" {
  description = "Port range for the forwarding rule (e.g., '80' or '80-81')."
  type        = string
  default     = "80"
}

variable "target_http_proxy_name" {
  description = "Name of the HTTP target proxy."
  type        = string
  default     = "l7-ilb-target-http-proxy"
}

variable "url_map_name" {
  description = "Name of the URL map."
  type        = string
  default     = "l7-ilb-regional-url-map"
}

variable "backend_service_name" {
  description = "Name of the backend service."
  type        = string
  default     = "l7-ilb-backend-subnet"
}

variable "backend_service_protocol" {
  description = "Protocol for the backend service (e.g., HTTP, HTTPS)."
  type        = string
  default     = "HTTP"
}

variable "backend_service_timeout_sec" {
  description = "Timeout for the backend service in seconds."
  type        = number
  default     = 10
}

variable "instance_template_name" {
  description = "Name of the instance template for the MIG."
  type        = string
  default     = "l7-ilb-mig-template"
}

variable "machine_type" {
  description = "Machine type for the instances in the MIG and the test instance."
  type        = string
  default     = "e2-small"
}

variable "disk_image" {
  description = "Disk image for the instances (e.g., 'debian-cloud/debian-12')."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "backend_tags" {
  description = "Network tags for backend instances, used by firewall rules."
  type        = list(string)
  default     = ["http-server"]
}

variable "instance_template_assign_external_ip" {
  description = "Whether to assign an external IP to instance templates. Generally false for ILB backends unless specific outbound internet access is required."
  type        = bool
  default     = false
}

variable "health_check_name" {
  description = "Name of the health check for the backend service."
  type        = string
  default     = "l7-ilb-hc"
}

variable "mig_name" {
  description = "Name of the Managed Instance Group."
  type        = string
  default     = "l7-ilb-mig1"
}

variable "mig_base_instance_name" {
  description = "Base name for instances created by the MIG."
  type        = string
  default     = "vm"
}

variable "mig_target_size" {
  description = "Desired number of instances in the MIG."
  type        = number
  default     = 2
}

variable "firewall_iap_hc_name" {
  description = "Name of the firewall rule allowing IAP and health check traffic."
  type        = string
  default     = "l7-ilb-fw-allow-iap-hc"
}

variable "firewall_iap_hc_source_ranges" {
  description = "Source IP ranges for IAP and health check traffic."
  type        = list(string)
  default     = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
}

variable "firewall_ilb_to_backends_name" {
  description = "Name of the firewall rule allowing traffic from the proxy subnet to backends."
  type        = string
  default     = "l7-ilb-fw-allow-ilb-to-backends"
}

variable "firewall_ilb_to_backends_ports" {
  description = "Ports allowed for traffic from the proxy subnet to backends."
  type        = list(string)
  default     = ["80", "443", "8080"]
}

variable "create_test_instance" {
  description = "Whether to create a test instance in the backend subnet for verification."
  type        = bool
  default     = true
}

variable "test_instance_name" {
  description = "Name of the test instance."
  type        = string
  default     = "l7-ilb-test-vm"
}

variable "test_instance_zone" {
  description = "Zone for the test instance (must be within the chosen region, e.g., 'europe-west1-b')."
  type        = string
  default     = "europe-west1-b"
}
