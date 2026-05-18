output "trigger_id" {
  value = google_cloudbuild_trigger.repo.trigger_id
}

output "build_sa_email" {
  value = google_service_account.build_sa.email
}
