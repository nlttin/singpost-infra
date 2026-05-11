locals {
  repository_id = "${var.project_name}-${var.env}-${var.repository_name}"

  common_labels = merge(
    var.labels,
    {
      project = var.project_name
      env     = var.env
      managed = "terraform"
    }
  )
}

# Enable API
resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = local.repository_id
  format        = var.format

  mode   = "STANDARD_REPOSITORY"
  labels = local.common_labels

  #   kms_key_name = var.kms_key_name

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" ? [1] : []

    content {
      immutable_tags = var.immutable_tags
    }
  }

  depends_on = [
    google_project_service.artifactregistry
  ]
}

# Writers
resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = toset(var.writer_members)

  project    = var.project_id
  location   = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name

  role   = "roles/artifactregistry.writer"
  member = each.value
}

# Readers
resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each = toset(var.reader_members)

  project    = var.project_id
  location   = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name

  role   = "roles/artifactregistry.reader"
  member = each.value
}
