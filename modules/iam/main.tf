data "google_project" "current" {}

locals {
  common_labels = merge(
    var.labels,
    {
      project = var.project_name
      env     = var.env
      managed = "terraform"
    }
  )

  service_account_email = google_service_account.github_actions.email
  workload_pool_name    = google_iam_workload_identity_pool.github_actions.name
  provider_name         = google_iam_workload_identity_pool_provider.github_actions.name

  # Cloud Build managed SA — project_number@cloudbuild.gserviceaccount.com
  # Docs: https://cloud.google.com/build/docs/cloud-build-service-account
  cloudbuild_sa = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_service" "apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "${var.project_name}-${var.env}-gh-pool"
  description               = "Workload Identity Pool for GitHub Actions"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = "${var.project_name}-${var.env}-gh-provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.actor"      = "assertion.actor"
    "attribute.owner"      = "assertion.repository_owner"
  }

  # Restricts token issuance to this specific GitHub repository.
  # Branch restriction removed for dev/test — add back for production:
  #   && assertion.ref == "refs/heads/main"
  # Docs: https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#conditions
  attribute_condition = "assertion.repository == \"${var.github_owner}/${var.github_repo}\""
}

resource "google_service_account" "github_actions" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "${var.project_name} ${var.env} GitHub Actions SA"
  description  = "Service account impersonated by GitHub Actions via Workload Identity Federation"
}

# Allow ONLY this GitHub repo to impersonate the service account.
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

# Project-level permissions for the GitHub Actions service account.
resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Cloud Build managed SA — push images to GAR after a successful build.
# Docs: https://cloud.google.com/build/docs/securing-builds/configure-access-for-cloud-build-service-account
resource "google_project_iam_member" "cloudbuild_gar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = local.cloudbuild_sa
}

# Cloud Build managed SA — stream build logs to Cloud Logging.
# Docs: https://cloud.google.com/build/docs/securing-builds/configure-access-for-cloud-build-service-account
resource "google_project_iam_member" "cloudbuild_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = local.cloudbuild_sa
}
