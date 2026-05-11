output "apigee_environment" {
  value = google_apigee_environment.env.name
}

output "apigee_instance" {
  value = google_apigee_instance.apigee_instance.name
}

output "apigee_org" {
  value = google_apigee_organization.apigee_org.name
}
