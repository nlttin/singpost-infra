output "service_name" {
  value = google_cloud_run_v2_service.cloudrun_app.name
}

output "service_uri" {
  value = google_cloud_run_v2_service.cloudrun_app.uri
}

output "service_account_email" {
  value = google_service_account.cloudrun_sa.email
}

output "vpc_connector_name" {
  value = google_vpc_access_connector.connector.name
}

output "vpc_connector_id" {
  value = google_vpc_access_connector.connector.id
}
