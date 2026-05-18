data "google_project" "current" {}

locals {
  build_sa_member = "serviceAccount:${google_service_account.build_sa.email}"
}

resource "google_project_service" "cloudbuild" {
  project            = var.project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "build_sa" {
  project      = var.project_id
  account_id   = "${var.env}-${var.repo_name}-build-sa"
  display_name = "${var.project_name} ${var.env} ${var.repo_name} Cloud Build SA"
}

resource "google_project_iam_member" "build_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = local.build_sa_member
}

resource "google_secret_manager_secret_iam_member" "build_sa_ghcr_pat" {
  secret_id = var.ghcr_pat_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.build_sa_member
}

# Cloud Build service agent cần tạo OIDC token cho build_sa khi dùng user-specified SA.
# Docs: https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts#permissions
resource "google_service_account_iam_member" "cloudbuild_sa_token_creator" {
  service_account_id = google_service_account.build_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "repo" {
  project         = var.project_id
  location        = var.region
  name            = "${var.project_name}-${var.env}-${var.repo_name}-trigger"
  service_account = google_service_account.build_sa.id
  filename        = "cloudbuild.yaml"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = var.github_branch
    }
  }

  substitutions = var.substitutions

  depends_on = [
    google_project_service.cloudbuild,
    google_project_iam_member.build_sa_log_writer,
    google_secret_manager_secret_iam_member.build_sa_ghcr_pat,
    google_service_account_iam_member.cloudbuild_sa_token_creator,
  ]
}
