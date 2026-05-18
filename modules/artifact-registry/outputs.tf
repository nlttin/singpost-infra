output "repository_id" {
  value = google_artifact_registry_repository.repo.repository_id
}

output "repository_name" {
  value = google_artifact_registry_repository.repo.name
}

output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "repository_location" {
  value = google_artifact_registry_repository.repo.location
}

output "ghcr_proxy_url" {
  value = var.enable_ghcr_proxy ? "${var.region}-docker.pkg.dev/${var.project_id}/${local.repository_id}-ghcr-proxy" : null
}
