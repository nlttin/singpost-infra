resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-${var.env}-vpc"
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

# GKE subnet
resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.project_name}-${var.env}-app-subnet"
  ip_cidr_range = var.app_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.project_name}-${var.env}-pods-range"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "${var.project_name}-${var.env}-services-range"
    ip_cidr_range = var.services_cidr
  }

  log_config {
    aggregation_interval = var.subnet_log_aggregation_interval
    flow_sampling        = 1.0
    metadata             = var.subnet_log_metadata
  }
}

resource "google_compute_router" "router" {
  name    = "${var.project_name}-${var.env}-router"
  network = google_compute_network.vpc.id
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "app_nat" {
  name   = "${var.project_name}-${var.env}-app-nat"
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.app_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ALL"
  }
}

# Private Service Connect for Cloud SQL
resource "google_compute_global_address" "private_service_range" {
  name          = "${var.project_name}-${var.env}-sql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

# Firewall
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-${var.env}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.vpc_cidr]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
