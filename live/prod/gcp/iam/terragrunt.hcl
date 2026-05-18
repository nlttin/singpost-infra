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
  github_branch = "main"

  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-actions-provider"

  service_account_id = "singpost-prod-github-actions-sa"

  project_roles = [
    "roles/cloudbuild.builds.editor",
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/storage.admin",
  ]

  labels = {
    workload = "github-actions"
  }
}
