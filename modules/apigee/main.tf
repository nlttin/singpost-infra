resource "google_project_service" "apis" {
  for_each = toset([
    "apigee.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

# Private service networking
resource "google_compute_global_address" "apigee_range" {
  name          = "${var.project_name}-${var.env}-apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 22
  network       = var.vpc_network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network = var.vpc_network_self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.apigee_range.name
  ]

  depends_on = [google_project_service.apis]
}

resource "google_apigee_organization" "apigee_org" {
  analytics_region = var.region
  project_id       = var.project_id
  display_name     = var.apigee_org_display_name

  authorized_network = var.vpc_network_self_link

  runtime_type = "CLOUD"

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_apigee_instance" "apigee_instance" {
  name     = "${var.project_name}-${var.env}-apigee-instance"
  location = var.region

  org_id = google_apigee_organization.apigee_org.id

  peering_cidr_range = var.runtime_cidr_range
}

resource "google_apigee_environment" "env" {
  org_id = google_apigee_organization.apigee_org.id
  name   = "${var.project_name}-apigee-env-${var.env}"
}

resource "google_apigee_instance_attachment" "env_attachment" {
  instance_id = google_apigee_instance.apigee_instance.id
  environment = google_apigee_environment.env.name
}

# API Proxy
resource "google_apigee_api" "cloudrun_proxy" {
  name = "${var.project_name}-${var.env}-cloudrun-proxy"

  org_id        = google_apigee_organization.apigee_org.id
  config_bundle = "apiproxy.zip"

  depends_on = [
    google_apigee_environment.env
  ]
}

resource "google_apigee_api_deployment" "deployment" {
  org_id      = google_apigee_organization.apigee_org.id
  environment = google_apigee_environment.env.name
  revision    = google_apigee_api.cloudrun_proxy.latest_revision_id
  proxy_id    = google_apigee_api.cloudrun_proxy.id
}
