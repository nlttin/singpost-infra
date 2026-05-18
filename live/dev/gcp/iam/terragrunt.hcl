include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam"
}

inputs = {
  github_owner = "nlttin"
  github_repositories = [
    "singpost-app-tracking",
    "singpost-app-ingestion",
  ]
  github_branch = "dev"

  # Workload Identity Federation
  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-actions-provider"

  service_account_id = "singpost-dev-github-actions-sa"

  project_roles = [
    "roles/cloudbuild.builds.editor",
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/storage.admin",
  ]

  cloudbuild_sa_emails = [
    "dev-app-tracking-build-sa@project-a8a37a94-04a7-44bf-a2c.iam.gserviceaccount.com",
    "dev-app-ingestion-build-sa@project-a8a37a94-04a7-44bf-a2c.iam.gserviceaccount.com",
  ]

  labels = {
    workload = "github-actions"
  }
}