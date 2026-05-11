include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam"
}

inputs = {
  # GitHub repository
  github_owner  = "your-github-org"
  github_repo   = "your-backend-api-repo"
  github_branch = "main"

  # Workload Identity Federation
  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-actions-provider"

  # Service Account
  service_account_id = "backend-api-github-actions-sa"

  # IAM roles for GitHub Actions
  project_roles = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
  ]

  labels = {
    workload = "github-actions"
    repo     = "backend-api"
  }
}