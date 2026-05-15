include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam"
}

inputs = {
  # GitHub — start with AppTracking; Ingestion/SFTP as separate stacks later
  github_owner = "nlttin"
  github_repo  = "singpost-app-tracking"

  # Workload Identity Federation
  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-actions-provider"

  # Service Account
  service_account_id = "singpost-dev-github-actions-sa"

  # IAM roles for GitHub Actions SA
  # roles/cloudbuild.builds.editor → trigger Cloud Build jobs
  # roles/run.admin                → deploy to Cloud Run
  # roles/iam.serviceAccountUser   → act-as Cloud Run runtime SA during deploy
  # roles/artifactregistry.writer  → push images to GAR
  # roles/logging.logWriter        → write deploy logs
  # roles/storage.objectAdmin      → upload source to gs://{project_id}_cloudbuild (required by gcloud builds submit)
  project_roles = [
    "roles/cloudbuild.builds.editor",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/storage.admin",
  ]

  labels = {
    workload = "github-actions"
    repo     = "singpost-app-tracking"
  }
}