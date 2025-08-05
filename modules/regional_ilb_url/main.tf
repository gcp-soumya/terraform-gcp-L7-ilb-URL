# VPC network
resource "google_compute_network" "ilb_network" {
  name                    = var.network_name
  provider                = google-beta
  auto_create_subnetworks = false
}

# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = var.proxy_subnet_name
  provider      = google-beta
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.ilb_network.id
}

# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = var.backend_subnet_name
  provider      = google-beta
  ip_cidr_range = var.backend_subnet_cidr
  region        = var.region
  network       = google_compute_network.ilb_network.id
}

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = var.forwarding_rule_name
  provider              = google-beta
  region                = var.region
  depends_on            = [google_compute_subnetwork.proxy_subnet] # Ensure proxy subnet is ready
  ip_protocol           = var.forwarding_rule_ip_protocol
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = var.forwarding_rule_port_range
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.ilb_network.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
  network_tier          = "PREMIUM"
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = var.target_http_proxy_name
  provider = google-beta
  region   = var.region
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = var.url_map_name
  provider        = google-beta
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = var.backend_service_name
  provider              = google-beta
  region                = var.region
  protocol              = var.backend_service_protocol
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = var.backend_service_timeout_sec
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "instance_template" {
  name         = var.instance_template_name
  provider     = google-beta
  machine_type = var.machine_type
  tags         = var.backend_tags

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    dynamic "access_config" {
      for_each = var.instance_template_assign_external_ip ? [1] : []
      content {}
    }
  }
  disk {
    source_image = var.disk_image
    auto_delete  = true
    boot         = true
  }

  metadata = {
    startup-script = <<-EOF
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF_INNER > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF_INNER
    EOF
  }
  lifecycle {
    create_before_destroy = true
  }
}

# health check
resource "google_compute_region_health_check" "default" {
  name     = var.health_check_name
  provider = google-beta
  region   = var.region
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# MIG
resource "google_compute_region_instance_group_manager" "mig" {
  name     = var.mig_name
  provider = google-beta
  region   = var.region
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = var.mig_base_instance_name
  target_size        = var.mig_target_size
}

# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw_iap" {
  name          = var.firewall_iap_hc_name
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = var.firewall_iap_hc_source_ranges
  allow {
    protocol = "tcp"
  }
}

# allow http from proxy subnet to backends
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = var.firewall_ilb_to_backends_name
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = [google_compute_subnetwork.proxy_subnet.ip_cidr_range] # Dynamically use the proxy subnet's CIDR
  target_tags   = var.backend_tags
  allow {
    protocol = "tcp"
    ports    = var.firewall_ilb_to_backends_ports
  }
}

# test instance (optional)
resource "google_compute_instance" "vm_test" {
  count        = var.create_test_instance ? 1 : 0
  name         = var.test_instance_name
  provider     = google-beta
  zone         = var.test_instance_zone
  machine_type = var.machine_type
  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
  }
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }
}
