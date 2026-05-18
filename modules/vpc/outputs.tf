# VPC
output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

# GKE subnet
output "app_subnet_name" {
  value = google_compute_subnetwork.app_subnet.name
}

output "app_subnet_self_link" {
  value = google_compute_subnetwork.app_subnet.self_link
}

# GKE secondary ranges
output "pods_secondary_range_name" {
  value = google_compute_subnetwork.app_subnet.secondary_ip_range[0].range_name
}

output "services_secondary_range_name" {
  value = google_compute_subnetwork.app_subnet.secondary_ip_range[1].range_name
}

# Router & NAT
output "router_name" {
  value = google_compute_router.router.name
}

output "router_self_link" {
  value = google_compute_router.router.self_link
}

output "nat_name" {
  value = google_compute_router_nat.app_nat.name
}
