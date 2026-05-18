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

  # Supports multiple repos — add branch restriction back for production.
  # Docs: https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#conditions
  attribute_condition = "assertion.repository in [${join(", ", formatlist("\"%s/%s\"", var.github_owner, var.github_repositories))}] && assertion.ref == \"refs/heads/${var.github_branch}\""
}

resource "google_service_account" "github_actions" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "${var.project_name}-${var.env}-github-actions-service-account"
  description  = "Service account impersonated by GitHub Actions via Workload Identity Federation"
}

# Allow each listed repo to impersonate the service account.
resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = toset(var.github_repositories)

  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${each.value}"
}

# Cloud Build service agent needs to create tokens for the build SA (user-specified SA in cloudbuild.yaml).
# Docs: https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts#permissions
resource "google_service_account_iam_member" "cloudbuild_token_creator" {
  for_each = toset(var.cloudbuild_sa_emails)

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

# Build SA needs to read the source archive uploaded by gcloud builds submit.
# Docs: https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts#permissions
resource "google_project_iam_member" "cloudbuild_sa_storage" {
  for_each = toset(var.cloudbuild_sa_emails)

  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${each.value}"
}

# Project-level permissions for the GitHub Actions service account.
resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
