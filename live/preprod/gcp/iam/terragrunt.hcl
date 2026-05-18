include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam"
}

inputs = {
  github_owner  = "your-github-org"
  github_repo   = "your-backend-api-repo"
  github_branch = "preprod"

  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-actions-provider"

  service_account_id = "backend-api-github-actions-sa"

  project_roles = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
    "roles/cloudbuild.builds.editor",
    "roles/storage.admin",
    "roles/logging.logWriter",
  ]

  labels = {
    workload = "github-actions"
    repo     = "backend-api"
  }
}
