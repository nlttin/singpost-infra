data "google_project" "current" {}

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

  mode         = "STANDARD_REPOSITORY"
  labels       = local.common_labels
  kms_key_name = var.kms_key_name

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

# Remote repository — proxies ghcr.io so Cloud Run can pull GHCR images.
# Cloud Run only accepts images from gcr.io, docker.pkg.dev, or docker.io.
resource "google_artifact_registry_repository" "ghcr_proxy" {
  count         = var.enable_ghcr_proxy ? 1 : 0
  project       = var.project_id
  location      = var.region
  repository_id = "${local.repository_id}-ghcr-proxy"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  labels        = local.common_labels

  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = "https://ghcr.io"
      }
    }
    upstream_credentials {
      username_password_credentials {
        username                = var.ghcr_username
        password_secret_version = var.ghcr_pat_secret_version
      }
    }
  }

  depends_on = [
    google_project_service.artifactregistry,
    google_secret_manager_secret_iam_member.ar_ghcr_pat,
  ]
}

# AR service agent needs to read the PAT secret to authenticate with GHCR.
resource "google_secret_manager_secret_iam_member" "ar_ghcr_pat" {
  count     = var.enable_ghcr_proxy ? 1 : 0
  secret_id = "github-pat"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
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
